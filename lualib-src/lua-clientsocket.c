// simple lua socket library for client
// It's only for demo, limited feature. Don't use it in your project.
// Rewrite socket library by yourself .

#include <lua.h>
#include <lauxlib.h>
#include <string.h>
#include <stdint.h>
#include <pthread.h>
#include <stdlib.h>

#include <netinet/in.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <errno.h>
#include <fcntl.h>

#define CACHE_SIZE 0x1000	

static int
lconnect(lua_State *L) {
	const char * addr = luaL_checkstring(L, 1);
	int port = luaL_checkinteger(L, 2);
	int fd = socket(AF_INET,SOCK_STREAM,0);
	struct sockaddr_in my_addr;

	my_addr.sin_addr.s_addr=inet_addr(addr);
	my_addr.sin_family=AF_INET;
	my_addr.sin_port=htons(port);

	int r = connect(fd,(struct sockaddr *)&my_addr,sizeof(struct sockaddr_in));

	if (r == -1) {
		return luaL_error(L, "Connect %s %d failed", addr, port);
	}

	int flag = fcntl(fd, F_GETFL, 0);
	fcntl(fd, F_SETFL, flag | O_NONBLOCK);

	lua_pushinteger(L, fd);

	return 1;
}

static int
lclose(lua_State *L) {
	int fd = luaL_checkinteger(L, 1);
	close(fd);

	return 0;
}

static void
block_send(lua_State *L, int fd, const char * buffer, int sz) {
	while(sz > 0) {
		int r = send(fd, buffer, sz, 0);
		if (r < 0) {
			if (errno == EAGAIN || errno == EINTR)
				continue;
			luaL_error(L, "socket error: %s", strerror(errno));
		}
		buffer += r;
		sz -= r;
	}
}

static void *
get_buffer(lua_State *L, int index, int *sz) {
	void *buffer;
	if (lua_isuserdata(L,index)) {
		buffer = lua_touserdata(L,index);
		*sz = luaL_checkinteger(L,index+1);
	} else {
		size_t len = 0;
		const char * str =  luaL_checklstring(L, index, &len);
		buffer = malloc(len);
		memcpy(buffer, str, len);
		*sz = (int)len;
	}
	return buffer;
}

static int
lsend2(lua_State *L) {
	int sz = 0;
	int fd = luaL_checkinteger(L,1);
	void *buffer = get_buffer(L, 2, &sz);
	block_send(L, fd, buffer, (int)sz);
	free(buffer);
	return 0;
}

///////////////////////////////////////////receive message////////////////////////////////////////////////
struct message {
    char *data;
    unsigned int size;
};

struct package_header {
    unsigned short size;
};

/*
 * send or recv message queue
 */
#define QUEUE_SIZE 64
struct messagequeue {
    pthread_mutex_t lock;
    int head;
    int tail;
    struct message* queue[QUEUE_SIZE];
};
static const unsigned int SOCKET_BUFF_SIZE = (0x1000);
static const unsigned int PACKAGE_HEADER_SIZE = sizeof(struct package_header);
static char databuff[0x1000 + 50] = {0};
static long databuff_unused = 0;
static struct messagequeue *recvqueue = NULL;

static struct message* message_malloc() {
    struct message *ret = (struct message*)malloc(sizeof(struct message));
    memset(ret, 0, sizeof(sizeof(struct message)));
    return ret;
}
static void message_free(struct message *message) {
    if (NULL != message) {
        free(message->data);
        message->data = NULL;
        free(message);
    }
}


static void
message_queue_pop(struct messagequeue *q) {
    pthread_mutex_lock(&q->lock);
    if (q->head == q->tail) {
        pthread_mutex_unlock(&q->lock);
        return;
    }
    struct message *ret = q->queue[q->head];
    if (ret) {
        q->queue[q->head] = NULL;
        if (++(q->head) >= QUEUE_SIZE) {
            q->head = 0;
        }
        pthread_mutex_unlock(&q->lock);
        message_free(ret);
    }
}

static struct message*
message_queue_head(struct messagequeue *q) {
    pthread_mutex_lock(&q->lock);
    if (q->head == q->tail) {
        pthread_mutex_unlock(&q->lock);
        return NULL;
    }
    struct message *ret = q->queue[q->head];
    pthread_mutex_unlock(&q->lock);
    return ret;
}

static int
message_queue_push(struct messagequeue *q, struct message *message) {
    pthread_mutex_lock(&q->lock);
    int next = (q->tail + 1) % QUEUE_SIZE;
    if (q->head == next) {
        pthread_mutex_unlock(&q->lock);
        return -1;
    }
    q->queue[q->tail] = message;
    q->tail = next;
    pthread_mutex_unlock(&q->lock);
    return 0;
}

static void
message_queue_clear(struct messagequeue *q) {
    while (1) {
        struct message *message = message_queue_head(q);
        if (message == NULL) break;
        message_queue_pop(q);
    }
}


int
clientsocket_pushmessage(struct messagequeue *q, const char *data, unsigned int size) {
    struct message *message = message_malloc();
    if (NULL == message) {
        printf("malloc message fail\n");
        return -1;
    }
    
    char *messagedata = (char *)malloc(size + 10);
    memset(messagedata, 0, size + 10);
    memcpy(messagedata, data, size);
    
    message->data = messagedata;
    message->size = size;
    
    int ret = message_queue_push(q, message);
    if (ret < 0) {
        message_free(message);
    }
    
    return ret;
}

static void
write_2byte(char *buffer, int val) {
    buffer[0] = (val >> 8) & 0xff;
    buffer[1] = val & 0xff;
}

static unsigned short
read_2byte(const char *buffer) {
    int val = 0;
    val = buffer[1] + (buffer[0] << 8);
    return val;
}

static void
clientsocket_parsebuff(struct messagequeue *q, char *databuff, long databuff_size, long *offset) {
    if (databuff_size <= 0) return;
    if (databuff_size > sizeof(struct package_header)) {
        struct package_header *header = (struct package_header*)databuff;
        unsigned int message_size = ntohs(header->size);
        if (databuff_size >= PACKAGE_HEADER_SIZE + message_size) {
            int ret = clientsocket_pushmessage(q, databuff, PACKAGE_HEADER_SIZE + message_size);
            if (ret < 0) {
                printf("[ERR]receive message fail, recev queue is full!");
            }
            
            *offset = *offset + message_size + PACKAGE_HEADER_SIZE;
            
            clientsocket_parsebuff(q, databuff + PACKAGE_HEADER_SIZE + message_size,
                                   databuff_size - PACKAGE_HEADER_SIZE - message_size,
                                   offset);
        }
    }
}



static void receive_message(int fd) {
	if (NULL == recvqueue) {
		recvqueue = (struct messagequeue*)malloc(sizeof(struct messagequeue));
		memset(recvqueue, 0, sizeof(struct messagequeue));
		pthread_mutex_init(&recvqueue->lock, NULL);
	}
	long recv_size = recv(fd, databuff + databuff_unused, SOCKET_BUFF_SIZE - databuff_unused, 0);
    if (recv_size > 0) {
        long offset = 0;
        long databuff_size = databuff_unused + recv_size;
        
        clientsocket_parsebuff(recvqueue, databuff, databuff_size, &offset);
        
        if (offset > 0 && offset < databuff_size) {
            memcpy(databuff, databuff + offset, databuff_size - offset);
        }
        
        databuff_unused = databuff_size - offset;
        if (databuff_unused < 0 || databuff_unused > SOCKET_BUFF_SIZE) {
            databuff_unused = 0;
        }
    } else if (0 == recv_size) {
        printf("[ERR]network disconnect");
        pthread_exit(0);
        return;
    }
}

int get_message(char *outdata) {
    if (NULL == recvqueue) {
        return 0;
    }
    struct message *message = message_queue_head(recvqueue);
    if (NULL == message) {
        return 0;
    }
    //int recvsize = read_2byte(message->data);
    //*prototype = read_2byte(message->data + 2);
    memcpy(outdata, message->data, message->size);
    //*outsize = message->size - 4;
    message_queue_pop(recvqueue);
    
    return message->size;
}

static int
lrecv2(lua_State *L) {

	int fd = luaL_checkinteger(L,1);
	receive_message(fd);
	//char buffer[CACHE_SIZE];
	//int r = recv(fd, buffer, CACHE_SIZE, 0);

	char buffer[CACHE_SIZE];
	int r = get_message(buffer);
	if (r == 0) {
		lua_pushliteral(L, "");
		lua_pushinteger(L, r);
		// close
		return 2;
	}
	if (r < 0) {
		if (errno == EAGAIN || errno == EINTR) {
			return 0;
		}
		luaL_error(L, "socket error: %s", strerror(errno));
	}

	lua_pushlightuserdata(L, (void*)(buffer+2));
	lua_pushinteger(L, r-2);
	return 2;
}

/*
	integer fd
	string message
 */
/*
static int
lsend(lua_State *L) {
	size_t sz = 0;
	int fd = luaL_checkinteger(L,1);
	const char * msg = luaL_checklstring(L, 2, &sz);

	block_send(L, fd, msg, (int)sz);

	return 0;
}
*/

/*
	intger fd
	string last
	table result

	return 
		boolean (true: data, false: block, nil: close)
		string last
 */

struct socket_buffer {
	void * buffer;
	int sz;
};

/*
static int
lrecv(lua_State *L) {
	int fd = luaL_checkinteger(L,1);

	char buffer[CACHE_SIZE];
	int r = recv(fd, buffer, CACHE_SIZE, 0);
	if (r == 0) {
		lua_pushliteral(L, "");
		// close
		return 1;
	}
	if (r < 0) {
		if (errno == EAGAIN || errno == EINTR) {
			return 0;
		}
		luaL_error(L, "socket error: %s", strerror(errno));
	}
	lua_pushlstring(L, buffer, r);
	return 1;
}
*/

static int
lusleep(lua_State *L) {
	int n = luaL_checknumber(L, 1);
	usleep(n);
	return 0;
}

// quick and dirty none block stdin readline

#define QUEUE_SIZE 1024

struct queue {
	pthread_mutex_t lock;
	int head;
	int tail;
	char * queue[QUEUE_SIZE];
};

static void *
readline_stdin(void * arg) {
	struct queue * q = arg;
	char tmp[1024];
	while (!feof(stdin)) {
		if (fgets(tmp,sizeof(tmp),stdin) == NULL) {
			// read stdin failed
			exit(1);
		}
		int n = strlen(tmp) -1;

		char * str = malloc(n+1);
		memcpy(str, tmp, n);
		str[n] = 0;

		pthread_mutex_lock(&q->lock);
		q->queue[q->tail] = str;

		if (++q->tail >= QUEUE_SIZE) {
			q->tail = 0;
		}
		if (q->head == q->tail) {
			// queue overflow
			exit(1);
		}
		pthread_mutex_unlock(&q->lock);
	}
	return NULL;
}

static int
lreadstdin(lua_State *L) {
	struct queue *q = lua_touserdata(L, lua_upvalueindex(1));
	pthread_mutex_lock(&q->lock);
	if (q->head == q->tail) {
		pthread_mutex_unlock(&q->lock);
		return 0;
	}
	char * str = q->queue[q->head];
	if (++q->head >= QUEUE_SIZE) {
		q->head = 0;
	}
	pthread_mutex_unlock(&q->lock);
	lua_pushstring(L, str);
	free(str);
	return 1;
}

int
luaopen_clientsocket(lua_State *L) {
	luaL_checkversion(L);
	luaL_Reg l[] = {
		{ "connect", lconnect },
		{ "recv", lrecv2 },
		{ "send", lsend2 },
		{ "close", lclose },
		{ "usleep", lusleep },
		{ NULL, NULL },
	};
	luaL_newlib(L, l);

	struct queue * q = lua_newuserdata(L, sizeof(*q));
	memset(q, 0, sizeof(*q));
	pthread_mutex_init(&q->lock, NULL);
	lua_pushcclosure(L, lreadstdin, 1);
	lua_setfield(L, -2, "readstdin");

	pthread_t pid ;
	pthread_create(&pid, NULL, readline_stdin, q);

	return 1;
}

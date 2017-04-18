#include <unistd.h> 
#include <sys/types.h> 
#include <stdio.h> 
#include <stdlib.h> 
int main(int argc,char * argv[]) 
{ 
	int count = atoi(argv[1]),i; 
	for(i=0;i<count;i++) 
	{ 
		pid_t pid = fork(); 
		if(pid == 0) 
		{ 
			//printf("child=%d ",getpid()); 
			system("gnome-terminal -x bash -c 'ulimit -n 1000000;cd /home/lee/server/skynet;./3rd/lua/lua ./gameclient/test_presure.lua'"); 
			exit(0); 
		} 
		sleep(2);
	} 
	exit(0); 
}

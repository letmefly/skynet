local netpack = require "netpack"
local protobuf = require "protobuf"
local protohelper = require "proto.protohelper"
local cjson = require "cjson"
local crypt = require "crypt"
local httpc = require "http.httpc"
local dns = require "dns"
local deskey = "skymobi-"

local http_server_addr = "127.0.0.1:80"
local doc_root_dir = "/php_01/html/v0/"
local http_tocken = "this_token"

local netutil = {}

function netutil.pbencode(msgname, msg)
	local msgtype = protohelper.gettype(msgname)
	local msgdata = protobuf.encode(msgname, msg)
	local buff, size = netpack.packpbc(msgtype, msgdata)
	return buff, size
end

function netutil.pbdecode(msgbuff, buffsize)
	local msgtype, buff, size = netpack.unpackpbc(msgbuff, buffsize)
	local msgname = protohelper.getname(msgtype)
	local msg = protobuf.decode(msgname, buff, size)
	return msgname, msg
end


function netutil.jsonencode(msgname, msg)
	local msgtype = protohelper.gettype(msgname)
	local msgdata = cjson.encode(msg)
	print("-> "..msgdata)
	--local base64fmt = crypt.base64encode(msgdata)
	--local desfmt = crypt.desencode(deskey, base64fmt)
	--local buff, size = netpack.packjson(msgtype, desfmt)
	local buff, size = netpack.packjson(msgtype, msgdata)
	return buff, size
end

function netutil.jsondecode(msgbuff, buffsize)
	local msgtype, buff, size= netpack.unpackjson(msgbuff, buffsize)
	local msgname = protohelper.getname(msgtype)
	--local base64fmt = crypt.desdecode(deskey, buff)
	--local jsonfmt = crypt.base64decode(base64fmt)
	--local msg = cjson.decode(jsonfmt)
	local msg = cjson.decode(buff)
	print("<- "..buff)
	return msgname, msg
end

function netutil.http_post(cmd, data)
	data.token = http_tocken
	return httpc.post2(http_server_addr, doc_root_dir..cmd, cjson.encode(data))
end

function netutil.http_do_cmd(cmd, data)
	data.cmd = cmd
	data.token = http_tocken
	print(cjson.encode(data))
	return httpc.post2(http_server_addr, doc_root_dir.."service_gateWay.php", cjson.encode(data))
end

return netutil

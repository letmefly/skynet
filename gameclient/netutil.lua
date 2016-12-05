local netpack = require "netpack"
local protobuf = require "protobuf"
local protohelper = require "proto.protohelper"
local cjson = require "cjson"
local crypt = require "crypt"

local deskey = "skymobi-"

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
	local base64fmt = crypt.base64encode(msgdata)
	local desfmt = crypt.desencode(deskey, base64fmt)
	local buff, size = netpack.packjson(msgtype, desfmt)
	return buff, size
end

function netutil.jsondecode(msgbuff, buffsize)
	local msgtype, buff, size = netpack.unpackjson(msgbuff, buffsize)
	local msgname = protohelper.getname(msgtype)
	local base64fmt = crypt.desdecode(deskey, buff)
	local jsonfmt = crypt.base64decode(base64fmt)
	local msg = cjson.decode(jsonfmt)
	return msgname, msg
end

return netutil

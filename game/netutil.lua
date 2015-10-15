local netpack = require "netpack"
local protobuf = require "protobuf"
local proto = require "proto.proto"

local netutil = {}

function netutil.pbencode(msgname, msg)
	local msgtype = proto.gettype(msgname)
	local msgdata = protobuf.encode(msgname, msg)
	local buff, size = netpack.packpbc(msgtype, msgdata)
	return buff, size
end

function netutil.pbdecode(msgbuff, buffsize)
	local msgtype, buff, size = netpack.unpackpbc(msgbuff, buffsize)
	local msgname = proto.getname(msgtype)
	local msg = protobuf.decode(msgname, buff, size)
	return msgname, msg
end

return netutil

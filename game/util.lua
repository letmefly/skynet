local netpack = require "netpack"
local protobuf = require "protobuf"
local proto = require "proto.proto"

local util = {}

function util.pbencode(msgname, msg)
	local msgtype = proto.gettype(msgname)
	local msgdata = protobuf.encode(msgname, msg)
	local buff, size = netpack.packpbc(msgtype, msgdata)
	return buff, size
end

function util.pbdecode(msgdata, msgsize)
	local msgtype, buff, size = netpack.unpackpbc(msgdata, msgsize)
	local msgname = proto.getname(msgtype)
	local msg = protobuf.decode(msgname, buff, size)
	return msgname, msg
end

return util

local protoparser = require "protoparser"
-- preload, execute one time
protoparser.load("proto.prototext")


local proto = {}

local type2name = {[1] = "register", [2] = "login", [3] = "handshake"}
local name2type = {}
for k, v in pairs(type2name) do
	name2type[v] = k
end
function proto.getname(type)
	return type2name[type]
end

function proto.gettype(name)
	return name2type[name]
end

return proto

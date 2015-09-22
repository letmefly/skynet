local skynet = require "skynet"
local netpack = require "netpack"

local CMD = {}

local function testProtobuf()
	protobuf = require "protobuf"
	parser = require "protoparser"

	t = parser.register("addressbook.proto","./game/proto")

	addressbook = {
		name = "Alice",
		id = 12345,
		phone = {
			{ number = "1301234567" },
			{ number = "87654321", type = "WORK" },
		}
	}
	--[[
	code = protobuf.encode("tutorial.Person", addressbook)

	local buff, size = netpack.packpbc(100, code)
	local prototype, buff, size = netpack.unpackpbc(buff, size)

	print("prototype: " .. prototype)

	decode = protobuf.decode("tutorial.Person" , buff, size)
	
	print(decode.name)
	print(decode.id)
	for _,v in ipairs(decode.phone) do
		print("\t"..v.number, v.type)
	end

	buffer = protobuf.pack("tutorial.Person name id", "Alice", 123)
	print(protobuf.unpack("tutorial.Person name id", buffer))
	]]
end

function CMD.testpbc(args)
	print("CMD.testpbc..."..args.a)
	testProtobuf()
	return {result="pbc ok"}
end

skynet.start(function()
	skynet.dispatch("lua", function(_,_, command, ...)
		local f = CMD[command]
		skynet.ret(skynet.pack(f(...)))
	end)
end)


local cjson = require "cjson"

local prototext = [[

message handshake {
  optional int32 sn = 1;
}

message user_register {
	optional string email = 2;
	optional string password = 3;
}

message user_register_ack {
	optional int32 err = 1;
}

message user_login {
	optional string email = 2;
	optional string password = 3;
}

message user_login_ack {
	optional int32 err = 1;
}

]]

local type2name_json = [[

{
	"1": "user_register",
	"2": "user_register_ack", 
	"3": "user_login", 
	"4": "user_login_ack",
	"5": "handshake"	
}

]]

local errno2desp_json = [[

{
	"1000": "用户已存在",
	"1001": "数据库错误",
	"1002": "用户名或者密码错误"
}

]]

PROTO_TYPE2NAME = {}

local type2name = cjson.decode(type2name_json)
for k, v in pairs(type2name) do
	PROTO_TYPE2NAME[tonumber(k)] = v
end

-- PROTO_TYPE2NAME = {
-- 	[1] = "user_register",
-- 	[2] = "user_register_ack", 
-- 	[3] = "user_login", 
-- 	[4] = "user_login_ack",
-- 	[5] = "handshake"
-- }

return prototext

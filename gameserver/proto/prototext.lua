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

PROTO_TYPE2NAME = {
	[1] = "user_register",
	[2] = "user_register_ack", 
	[3] = "user_login", 
	[4] = "user_login_ack",
	[5] = "handshake"
}

return prototext

local prototext = [[

message handshake {
  optional int32 sn = 1;
}

]]

PROTO_TYPE2NAME = {
	[1] = "register", 
	[2] = "login", 
	[3] = "handshake"
}

return prototext

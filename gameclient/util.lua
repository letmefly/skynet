package.cpath = "luaclib/?.so"
package.path = "lualib/?.lua;gameclient/?.lua;gameclient/?/?.lua"

if _VERSION ~= "Lua 5.3" then
	error "Use lua 5.3"
end

local netutil = require "netutil"
local socket = require "clientsocket"
local cjson = require "cjson"

local util = {}
local msg_handler_tab = {}

local function dump(obj)
    local getIndent, quoteStr, wrapKey, wrapVal, dumpObj
    getIndent = function(level)
        return string.rep("    ", level)
    end
    quoteStr = function(str)
        return '"' .. string.gsub(str, '"', '\\"') .. '"'
    end
    wrapKey = function(val)
        if type(val) == "number" then
            return "[" .. val .. "]"
        elseif type(val) == "string" then
            return "[" .. quoteStr(val) .. "]"
        else
            return "[" .. tostring(val) .. "]"
        end
    end
    wrapVal = function(val, level)
        if type(val) == "table" then
            return dumpObj(val, level)
        elseif type(val) == "number" then
            return val
        elseif type(val) == "string" then
            return quoteStr(val)
        else
            return tostring(val)
        end
    end
    dumpObj = function(obj, level)
        if type(obj) ~= "table" then
            return wrapVal(obj)
        end
        level = level + 1
        local tokens = {}
        tokens[#tokens + 1] = "{"
        for k, v in pairs(obj) do
            tokens[#tokens + 1] = getIndent(level) .. wrapKey(k) .. " = " .. wrapVal(v, level) .. ","
        end
        tokens[#tokens + 1] = getIndent(level - 1) .. "}"
        return table.concat(tokens, "\n")
    end
    return dumpObj(obj, 0)
end

function util.reg(msgname, msghandler)
    msg_handler_tab[msgname] = msghandler
end

function util.msg_poll(fd)
    while true do
        local buff, size = socket.recv(fd)
        if size and size > 0 then
            -- print ("msg size:" .. size)
            local msgname, msg = netutil.pbdecode(buff, size)
            -- print(msgname .. ":" .. msg.errno)
            -- print(msgname..":"..cjson.encode(msg))
            print("---"..msgname.."---")
            util.print(msg)
            if msg_handler_tab[msgname] then
                msg_handler_tab[msgname](msg)
            end
        else
            socket.usleep(100)
        end
    end
end

function util.print(t)
	-- print("")
	print(dump(t))
	print("")
end

function util.sendmsg(fd, msgname, msg)
	print("---"..msgname.."---")
	util.print(msg)
	local msgdata, size = netutil.pbencode(msgname, msg)
	socket.send(fd, msgdata, size)
end

function util.recvmsg(fd)
	while true do
		local buff, size = socket.recv(fd)
		if size and size > 0 then
			-- print ("msg size:" .. size)
			local msgname, msg = netutil.pbdecode(buff, size)
			-- print(msgname .. ":" .. msg.errno)
			-- print(msgname..":"..cjson.encode(msg))
			print("---"..msgname.."---")
			util.print(msg)
			return msgname, msg
		else
			socket.usleep(5)
		end
	end
end

function util.sendmsg2(fd, msgname, msg)
    print("---"..msgname.."---")
    util.print(msg)
    local msgdata, size = netutil.jsonencode(msgname, msg)
    socket.send(fd, msgdata, size)
end

function util.recvmsg2(fd)
    while true do
        local buff, size = socket.recv(fd)
        if size and size > 0 then
            -- print ("msg size:" .. size)
            local msgname, msg = netutil.jsondecode(buff, size)
            -- print(msgname .. ":" .. msg.errno)
            -- print(msgname..":"..cjson.encode(msg))
            print("---"..msgname.."---")
            util.print(msg)
            return msg
        else
            socket.usleep(100)
        end
    end
end

return util

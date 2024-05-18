local module = {}
module.__index = module

local SocketModule = require("socket")
local ClientClass = require("ConnectedClient")

local function splitString(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t = {}
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		table.insert(t, str)
	end
	return t
end


module.new = function(port, maxtimeout)
    local self = setmetatable({}, module)
    
    self.Port = port
    self.DataSeparator = "/-/"

    self.UDP = SocketModule.udp()
    self.UDP:setsockname("localhost", port)
    self.UDP:settimeout(maxtimeout or 0)

    self.ConnectedClients = {}
    self.ClientTimeoutLength = 5

    self.LastMessage = ""
    self.LastMessageTime = os.clock()

    return self
end

local idSerial = 0
function module:CreateUniqueId()
    idSerial = idSerial + 1
    return idSerial
end

function module:ConnectClient(ip, port)
    local newId = self:CreateUniqueId()
    local newClient = ClientClass.new(self, newId, ip, port)
    self.ConnectedClients[newId] = newClient

    newClient:SendMessage("id:"..newId)
end

function module:Tick()
    local data, msgOrIp, portOrNil = self.UDP:receivefrom()
    if msgOrIp == "timeout" then return end -- no message
    
    -- print(data)
    -- print(msgOrIp, portOrNil)
    -- print("--------")
    if msgOrIp and portOrNil then
        local splitData = splitString(data, self.DataSeparator)
        local uniqueID = splitData[1]
        local actionName = splitData[2] -- join, p2p, all

        if uniqueID == "?" and actionName == "join" then
            self:ConnectClient(msgOrIp, portOrNil)
            return
        end

        local client = self.ConnectedClients[uniqueID]
        if not client then return end

        self.LastMessage = data
        self.LastMessageTime = os.clock()

        client.LastRecivedMessage = os.clock()
        client:SendMessage("gotData")

        if actionName == "p2p" then
            local otherIP = splitData[3]
            local otherClient = self.ConnectedClients[otherIP]
            if otherClient then
                otherClient:SendMessage()
            end
        end
        for ip, otherClient in pairs(self.ConnectedClients) do
            if ip ~= msgOrIp then
                otherClient:SendMessage(data)
            end
        end
    end

    self:CleanClients()
end

function module:CleanClients()
    for ip, client in pairs(self.ConnectedClients) do
        if os.clock() - client.LastRecivedMessage > self.ClientTimeoutLength then
            client:Destroy()
        end
    end 
end

local lineHeight = 16

local msgCount = 0
local function resetMsgs()
    msgCount = 0
end
local function msg(text, maxWidth)
    love.graphics.printf(text, 0, lineHeight*msgCount, maxWidth or 500)
    msgCount = msgCount+1
end


function module:DrawInfo()
    resetMsgs()
    msg("Server Window: port:"..tostring(self.Port))
    local timeResolution = 10
    msg("Time Since Last Message: "..tostring(math.floor((os.clock() - self.LastMessageTime)*timeResolution)/timeResolution), math.huge)
    msg("Active Connections:")

    for id in pairs(self.ConnectedClients) do
        msg("\t"..id)
    end
end

function module:Destroy()
    for ip, client in pairs(self.ConnectedClients) do
        self:RemoveClient(ip)
    end
end

return module
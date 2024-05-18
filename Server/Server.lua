local module = {}
module.__index = module

local enet = require "enet"

module.new = function(port, maxtimeout)
    local self = setmetatable({}, module)
    
    self.Port = port
    self.Identity = "localhost:"..tostring(self.Port)

    self.Host = enet.host_create(self.Identity)
    self.ConnectedClients = {}

    return self
end

function module:Tick()
    local event = self.Host:service(100)
    while event do
        
        if event.type == "receive" then
            -- print("Got message: ", event.data, event.peer)
            event.peer:send( "pong" )
            self.Host:broadcast(event.data)

        elseif event.type == "connect" then
            print(event.peer, "connected.")
            self.ConnectedClients[event.peer] = true

        elseif event.type == "disconnect" then
            print(event.peer, "disconnected.")
            self.ConnectedClients[event.peer] = nil
            
        end
        event = self.Host:service()
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
    msg("Server Window")
    msg("Port: "..tostring(self.Port))

    local peerCount = 0
    for _ in pairs(self.ConnectedClients) do
        peerCount = peerCount + 1
    end
    msg("Active Connections: " .. tostring(peerCount))
end


function module:Destroy()
end

return module
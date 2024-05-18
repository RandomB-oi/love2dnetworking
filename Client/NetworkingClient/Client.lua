local module = {}
module.__index = module

local ENet = require("enet")
local NetworkSignalClass = require("NetworkingClient.NetworkSignal")
local lualzw = require("NetworkingClient.lualzw")

local Transformer = require("NetworkingClient.DataTransformer")

module.new = function(address, port)
    local self = setmetatable({}, module)
    print("Playing multiplayer")
    print("Joining ip "..tostring(address).." on port "..tostring(port))

    self.IP = address
    self.Port = port
    self.ServerIdentity = tostring(self.IP)..":"..tostring(self.Port)
    self.DataSeparator = "/-/"

    self.Host = ENet.host_create()
    self.Server = self.Host:connect(self.ServerIdentity)

    self.NetworkTPS = 1/10
    self.LastNetworkTick = -math.huge

    self.DataRecived = NetworkSignalClass.new()

    

    self:Send("newClient")

    return self
end

function module:Send(jobName, jobData)
    local data = {n=jobName, d=jobData}
    local message = Transformer.Save(data)
    local compressed = "cmp"..lualzw.compress(message)

    self.Host:service(100)
	self.Server:send(compressed)
end

function module:SendMessage(message)
    self.Host:service(100)
	self.Server:send(message)
end

function module:Tick()
    local t = os.clock()
    if t - self.LastNetworkTick < self.NetworkTPS then return end
    self.LastNetworkTick = t

    local event = self.Host:service(100)
    while event do
        if event.type == "receive" then
            local message = event.data
            if message:sub(1,3) == "cmp" then
                message = message:sub(4,-1)
                message = Transformer.Load(lualzw.decompress(message))
                self.DataRecived:Fire(message.n, message.d)
            else
                self.DataRecived:Fire("unknown", message)
            end

        elseif event.type == "connect" then
            print(event.peer, "connected.")

            event.peer:send( "ping" )
        elseif event.type == "disconnect" then
            print(event.peer, "disconnected.")
        end
        event = self.Host:service()
    end
end

return module
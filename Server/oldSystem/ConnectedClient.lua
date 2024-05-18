local module = {}
module.__index = module

module.new = function(server, id, ip, port)
    local self = setmetatable({}, module)
    self.ConnectedServer = server
    
    self.ID = id
    self.IP = ip
    self.Port = port

    self.LastRecivedMessage = os.clock()

    self.ConnectedServer.ConnectedClients[self.ID] = self
    self:SendMessage("connected")

    return self
end

function module:SendMessage(message)
    self.ConnectedServer.UDP:sendto(message, self.IP, self.Port)
end

function module:Destroy()
    self.ConnectedServer.ConnectedClients[self.ID] = nil
end

return module
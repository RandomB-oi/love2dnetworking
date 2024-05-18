local module = {}
module.__index = module
	
module.new = function()
	return setmetatable({connections = {}}, module)
end

function module:Connect(callback)
	local connection = {
		_callback = callback,
		Disconnect = function(connection)
			for i,v in ipairs(self.connections) do
				if v == connection then
					table.remove(self.connections, i)
					break
				end
			end
		end,
	}
	table.insert(self.connections, connection)
	return connection
end

function module:Once(callback)
	local connection connection = self:Connect(function(...)
		connection:Disconnect()
		coroutine.wrap(callback)(...)
	end)
end

function module:Wait()
	local thread = coroutine.running()
	self:Once(function(...)
		coroutine.resume(thread, ...)
	end)
	return coroutine.yield()
end

function module:Fire(...)
	local args = {...}
	
    for _, connection in pairs(self.connections) do
        if type(connection) == "table" then
            xpcall(coroutine.wrap(connection._callback), function(err)
                warn(err, debug.traceback())
            end, unpack(args))
        end
    end
end

function module:Destroy()
	self.connections = {}
end

return module
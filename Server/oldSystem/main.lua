local ServerClass = require("Server")


--[[
fire to specific clients
give players unique ids
clients can fire other clients
clients can fire all clients
]]

function love.load()
    love.window.setTitle("Server")
    love.window.setMode(300, 200, {resizable = true})

    local newServer = ServerClass.new(8080, 0)

    function love.update()
        newServer:Tick()
    end

    function love.draw()
        newServer:DrawInfo()
    end
end
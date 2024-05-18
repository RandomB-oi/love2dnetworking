local ClientClass = require("NetworkingClient.Client")


function love.load()
    love.window.setTitle("Client")
    love.window.setMode(300, 200, {resizable = true})

    local newClient = ClientClass.new("localhost", 8080)

    function love.update()
        newClient:Tick()
    end
end
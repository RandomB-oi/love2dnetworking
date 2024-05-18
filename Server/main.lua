local ServerClass = require("Server")


function love.load()
    love.window.setTitle("Server")
    love.window.setMode(300, 200, {resizable = true})

    local newServer = ServerClass.new(8080, 0)

    local buttonX, buttonY = 0, 0
    local buttonW, buttonH = 200, 50
    local buttonHover = false

    function love.update()
        buttonX = 6
        buttonY = love.graphics.getHeight() - buttonH - 6

        local mouseX, mouseY = love.mouse.getPosition()
        buttonHover = mouseX > buttonX and mouseX < buttonX + buttonW and mouseY > buttonY and mouseY < buttonY + buttonY

        newServer:Tick()
    end

    function love.draw()
        love.graphics.setColor(1,1,1,1)
        newServer:DrawInfo()


        if buttonHover then
            love.graphics.setColor(0.8, 0.8, 0.8, 1)
        else
            love.graphics.setColor(1, 1, 1, 1)
        end
        love.graphics.rectangle("fill", buttonX, buttonY, buttonW, buttonH)
    end

    function love.mousepressed(x,y, button)
        if button == 1 and buttonHover then
            newServer:DisconnectAll()
        end
    end
end
-- LOVE2D Game: The Flight of The Bubble

-- Screen dimensions
local screenWidth, screenHeight = 800, 600

-- Game state
local gameState = "menu" -- "menu", "playing", "paused", "gameover"

-- Player (the bubble)
local player = {
    x = screenWidth / 2,
    y = screenHeight - 50,
    radius = 20,
    speed = 200,
    velocityY = -50 -- Initial upward movement
}

-- Obstacles
local obstacles = {}
local obstacleTimer = 0
local obstacleInterval = 1.5

-- Score
local score = 0
local distanceTraveled = 0

function love.load()
    love.window.setMode(screenWidth, screenHeight)
    love.window.setTitle("The Flight of The Bubble")
end

function love.update(dt)
    if gameState == "playing" then
        -- Update player position based on input
        if love.keyboard.isDown("w") or love.keyboard.isDown("up") then
            player.y = player.y - player.speed * dt
        end
        if love.keyboard.isDown("a") or love.keyboard.isDown("left") then
            player.x = player.x - player.speed * dt
        end
        if love.keyboard.isDown("s") or love.keyboard.isDown("down") then
            player.y = player.y + player.speed * dt
        end
        if love.keyboard.isDown("d") or love.keyboard.isDown("right") then
            player.x = player.x + player.speed * dt
        end

        -- Add upward movement
        player.y = player.y + player.velocityY * dt

        -- Prevent the player from going off-screen horizontally
        if player.x - player.radius < 0 then
            player.x = player.radius
        elseif player.x + player.radius > screenWidth then
            player.x = screenWidth - player.radius
        end

        -- Prevent the player from going off-screen vertically
        if player.y - player.radius < 0 then
            player.y = player.radius
        elseif player.y + player.radius > screenHeight then
            player.y = screenHeight - player.radius
        end

        -- Generate obstacles
        obstacleTimer = obstacleTimer + dt
        if obstacleTimer >= obstacleInterval then
            obstacleTimer = 0
            table.insert(obstacles, {
                x = math.random(0, screenWidth - 50),
                y = player.y - screenHeight,
                width = math.random(50, 150),
                height = 20
            })
        end

        -- Move obstacles and check for collisions
        for i = #obstacles, 1, -1 do
            obstacles[i].y = obstacles[i].y + 200 * dt

            if checkCollision(player, obstacles[i]) then
                gameState = "gameover"
            end

            -- Remove obstacles that go off-screen
            if obstacles[i].y > screenHeight then
                table.remove(obstacles, i)
                score = score + 1
            end
        end

        -- Update distance traveled
        distanceTraveled = distanceTraveled - player.velocityY * dt
    end
end



function love.draw()
    if gameState == "menu" then
        drawMenu()
    elseif gameState == "playing" then
        drawGame()
    elseif gameState == "paused" then
        drawPaused()
    elseif gameState == "gameover" then
        drawGameOver()
    end
end

function love.keypressed(key)
    if key == "escape" then
        if gameState == "playing" then
            gameState = "paused"
        elseif gameState == "paused" then
            gameState = "playing"
        elseif gameState == "menu" then
            love.event.quit()
        elseif gameState == "gameover" then
            love.event.quit()
        end
    elseif key == "return" then
        if gameState == "menu" or gameState == "gameover" then
            restartGame()
        end
    end
end

function checkCollision(player, obstacle)
    return player.x + player.radius > obstacle.x and
           player.x - player.radius < obstacle.x + obstacle.width and
           player.y + player.radius > obstacle.y and
           player.y - player.radius < obstacle.y + obstacle.height
end

function drawMenu()
    love.graphics.printf("The Flight of The Bubble", 0, screenHeight / 3, screenWidth, "center")
    love.graphics.printf("Press Enter to Play", 0, screenHeight / 2, screenWidth, "center")
    love.graphics.printf("Press Escape to Quit", 0, screenHeight / 1.5, screenWidth, "center")
end

function drawGame()
    -- Draw player
    love.graphics.circle("fill", player.x, player.y, player.radius)

    -- Draw obstacles
    for _, obstacle in ipairs(obstacles) do
        love.graphics.rectangle("fill", obstacle.x, obstacle.y, obstacle.width, obstacle.height)
    end

    -- Draw score
    love.graphics.printf("Score: " .. score, 10, 10, screenWidth, "left")
end

function drawPaused()
    love.graphics.printf("Paused", 0, screenHeight / 2, screenWidth, "center")
    love.graphics.printf("Press Escape to Resume", 0, screenHeight / 1.5, screenWidth, "center")
end

function drawGameOver()
    love.graphics.printf("Game Over", 0, screenHeight / 3, screenWidth, "center")
    love.graphics.printf("Score: " .. score, 0, screenHeight / 2, screenWidth, "center")
    love.graphics.printf("Press Enter to Play Again", 0, screenHeight / 1.5, screenWidth, "center")
    love.graphics.printf("Press Escape to Quit", 0, screenHeight / 1.3, screenWidth, "center")
end

function restartGame()
    gameState = "playing"
    player.x = screenWidth / 2
    player.y = screenHeight - 50
    player.velocityY = -50
    obstacles = {}
    score = 0
    distanceTraveled = 0
end

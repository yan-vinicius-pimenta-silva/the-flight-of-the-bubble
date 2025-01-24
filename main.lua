-- LOVE2D Game: Go Bubble!

-- Screen dimensions
local screenWidth, screenHeight = 640, 640

-- Game state
local gameState = "menu" -- "menu", "playing", "paused", "gameover"

-- Player (the bubble)
local player = {
    x = screenWidth / 2,
    y = screenHeight - 50,
    radius = 20,
    speed = 200,
    velocityY = -50, -- Initial upward movement
    animation = {},
    currentFrame = 1,
    animationTimer = 0,
    animationInterval = 0.1 -- Time between frames
}

-- Backgrounds
local backgrounds = {}
local currentBackgroundIndex = 1

-- Obstacles
local obstacles = {}
local obstacleTimer = 0
local obstacleInterval = 0.5

-- Score
local score = 0
local distanceTraveled = 0

-- Menu assets
local menuImage
local playButton = {x = 220, y = 300, width = 200, height = 50}
local quitButton = {x = 220, y = 400, width = 200, height = 50}

-- Game Over assets
local gameOverImage
local restartButton = {x = 220, y = 300, width = 200, height = 50}
local exitButton = {x = 220, y = 400, width = 200, height = 50}

-- Gameplay music
local gameplayMusic

-- Customized cursor
local customCursor



function love.load()
    love.window.setMode(screenWidth, screenHeight)
    love.window.setTitle("The Flight of The Bubble")

    -- Load player animation frames
    player.animation = {
        love.graphics.newImage("Bubble1.png"),
        love.graphics.newImage("Bubble2.png"),
        love.graphics.newImage("Bubble3.png"),
        love.graphics.newImage("Bubble4.png")
    }

    -- Load background images
    backgrounds = {
        love.graphics.newImage("day.png"),
        love.graphics.newImage("afternoon.png"),
        love.graphics.newImage("night.png")
    }

    -- Load menu image
    menuImage = love.graphics.newImage("start.png")

    -- Load game over image
    gameOverImage = love.graphics.newImage("gameover.png")

    -- Load obstacle sprites
    obstacleSprites = {
        love.graphics.newImage("cometa1.png"),
        love.graphics.newImage("rocket.png"),
        love.graphics.newImage("plane1.png")
    }

    

    -- Load gameplay music
    gameplayMusic = love.audio.newSource("song1.mp3", "stream")
    gameplayMusic:setVolume(0.5) -- Ajusta o volume para 50%
    gameplayMusic:setLooping(true) -- Set the music to loop
end

function love.update(dt)
    if gameState == "playing" then
        -- Play the gameplay music if it's not already playing
        if not gameplayMusic:isPlaying() then
            gameplayMusic:play()
        end

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

        -- Update animation frame
        player.animationTimer = player.animationTimer + dt
        if player.animationTimer >= player.animationInterval then
            player.animationTimer = 0
            player.currentFrame = player.currentFrame % #player.animation + 1
        end

        -- Generate obstacles
        obstacleTimer = obstacleTimer + dt
        if obstacleTimer >= obstacleInterval then
            obstacleTimer = 0
            table.insert(obstacles, {
                sprite = obstacleSprites[math.random(#obstacleSprites)],
                x = math.random(0, screenWidth - 50),
                y = -50,
                width = 50, -- You can adjust based on sprite size
                height = 50 -- You can adjust based on sprite size
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

                -- Update background based on score
                if score % 50 == 0 then
                    currentBackgroundIndex = (currentBackgroundIndex % #backgrounds) + 1
                end
            end
        end

        -- Update distance traveled
        distanceTraveled = distanceTraveled - player.velocityY * dt
    else
        -- Stop the gameplay music if the game is not in the playing state
        if gameplayMusic:isPlaying() then
            gameplayMusic:stop()
        end
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

function love.mousepressed(x, y, button)
    if button == 1 then
        if gameState == "menu" then
            if isMouseOver(playButton, x, y) then
                restartGame()
            elseif isMouseOver(quitButton, x, y) then
                love.event.quit()
            end
        elseif gameState == "gameover" then
            if isMouseOver(restartButton, x, y) then
                restartGame()
            elseif isMouseOver(exitButton, x, y) then
                love.event.quit()
            end
        end
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
    love.graphics.draw(menuImage, 0, 0)
end

function drawPaused()
    love.graphics.setColor(0, 0, 0, 0.5) -- Fundo semi-transparente
    love.graphics.rectangle("fill", 0, 0, screenWidth, screenHeight)
    love.graphics.setColor(1, 1, 1, 1) -- Texto branco
    love.graphics.printf("Paused", 0, screenHeight / 2 - 30, screenWidth, "center")
    love.graphics.printf("Press Escape to Resume", 0, screenHeight / 2, screenWidth, "center")
end

function drawGameOver()
    love.graphics.draw(gameOverImage, 0, 0)
end

function drawGame()
    -- Draw current background
    love.graphics.draw(backgrounds[currentBackgroundIndex], 0, 0, 0, screenWidth / backgrounds[currentBackgroundIndex]:getWidth(), screenHeight / backgrounds[currentBackgroundIndex]:getHeight())

    -- Draw player
    love.graphics.draw(player.animation[player.currentFrame], player.x - player.radius, player.y - player.radius, 0, 1, 1)

    -- Draw obstacles
    for _, obstacle in ipairs(obstacles) do
        love.graphics.draw(obstacle.sprite, obstacle.x, obstacle.y, 0, obstacle.width / obstacle.sprite:getWidth(), obstacle.height / obstacle.sprite:getHeight())
    end

    -- Draw score
    love.graphics.printf("Score: " .. score, 10, 10, screenWidth, "left")
end


function isMouseOver(button, mx, my)
    return mx > button.x and mx < button.x + button.width and
           my > button.y and my < button.y + button.height
end

function restartGame()
    gameState = "playing"
    player.x = screenWidth / 2
    player.y = screenHeight - 50
    player.velocityY = -50
    player.currentFrame = 1
    player.animationTimer = 0
    obstacles = {}
    score = 0
    distanceTraveled = 0
    currentBackgroundIndex = 1
end

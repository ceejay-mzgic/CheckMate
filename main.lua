-- main.lua
local StateManager = require("state_manager")
local MenuState    = require("states.menu")
local GameState    = require("states.game")


local stateManager

function love.load()
    love.window.setTitle("CheckMate")

    stateManager = StateManager.new()

    local menu = MenuState:new(stateManager)
    local game = GameState:new(stateManager)

    stateManager:register("menu", menu)
    stateManager:register("game", game)


    stateManager:switch("menu")
end

function love.update(dt)
    stateManager:update(dt)


    if love.keyboard.isDown("escape") then
        stateManager:switch("menu")
    end 
end

function love.draw()
    stateManager:draw()
end

function love.mousepressed(x, y, button)
    stateManager:mousepressed(x, y, button)
end

function love.keypressed(key)
    if stateManager and stateManager.current and stateManager.current.keypressed then
        stateManager.current:keypressed(key)
    end
end

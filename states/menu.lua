local menu = {}
menu.__index = menu

function menu:new(stateManager)
    local self = setmetatable({}, menu)

    self.stateManager = stateManager

    self.buttonWidth   = 300
    self.buttonHeight  = 70
    self.buttonSpacing = 20

    self.title = "CheckMate"

    self.titleFont  = love.graphics.newFont(64)
    self.buttonFont = love.graphics.newFont(32)

    self.buttons = {}

    return self
end

function menu:buildLayout()
    local screenW = love.graphics.getWidth()
    local screenH = love.graphics.getHeight()

    local totalHeight = self.buttonHeight * 2 + self.buttonSpacing
    local startY = (screenH - totalHeight) / 2

    self.buttons = {
        {
            label = "Play",
            x = (screenW - self.buttonWidth) / 2,
            y = startY,
            w = self.buttonWidth,
            h = self.buttonHeight,
            onClick = function()
                self.stateManager:switch("game")
            end
        },
        {
            label = "Quit",
            x = (screenW - self.buttonWidth) / 2,
            y = startY + self.buttonHeight + self.buttonSpacing,
            w = self.buttonWidth,
            h = self.buttonHeight,
            onClick = function()
                love.event.quit()
            end
        }
    }
end

function menu:enter()
    self:buildLayout()
end

function menu:update(dt)
end

function menu:draw()
    local screenW = love.graphics.getWidth()

    love.graphics.clear(0.1, 0.1, 0.15)

    love.graphics.setFont(self.titleFont)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(
        self.title,
        0,
        120,
        screenW,
        "center"
    )

    love.graphics.setFont(self.buttonFont)

    for _, b in ipairs(self.buttons) do
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("line", b.x, b.y, b.w, b.h, 10)

        local ty = b.y + (b.h - self.buttonFont:getHeight()) / 2
        love.graphics.printf(b.label, b.x, ty, b.w, "center")
    end
end

function menu:mousepressed(x, y, button)
    if button ~= 1 then return end

    for _, b in ipairs(self.buttons) do
        if x >= b.x and x <= b.x + b.w and
           y >= b.y and y <= b.y + b.h then
            if b.onClick then b.onClick() end
            return
        end
    end
end

return menu
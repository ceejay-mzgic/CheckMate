local StateManager = {}
StateManager.__index = StateManager

function StateManager.new()
    local self = setmetatable({}, StateManager)
    self.states = {}
    self.current = nil
    return self
end

function StateManager:register(name, state)
    self.states[name] = state
end

function StateManager:switch(name, params)
    local state = self.states[name]
    if not state then
        error("State '" .. tostring(name) .. "' not found")
    end

    self.current = state
    if self.current.enter then
        self.current:enter(params)
    end
end

function StateManager:update(dt)
    if self.current and self.current.update then
        self.current:update(dt)
    end
end

function StateManager:draw()
    if self.current and self.current.draw then
        self.current:draw()
    end
end

function StateManager:mousepressed(x, y, button)
    if self.current and self.current.mousepressed then
        self.current:mousepressed(x, y, button)
    end
end

return StateManager
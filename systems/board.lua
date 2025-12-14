-- systems/board.lua
local Board = {}
Board.__index = Board

function Board.new(rows, cols)
    local self = setmetatable({}, Board)
    self.rows = rows
    self.cols = cols
    self.grid = {}
    for r = 1, rows do
        self.grid[r] = {}
        for c = 1, cols do
            self.grid[r][c] = nil
        end
    end
    return self
end

function Board:clear()
    for r = 1, self.rows do
        for c = 1, self.cols do
            self.grid[r][c] = nil
        end
    end
end

function Board:inBounds(r, c)
    return r >= 1 and r <= self.rows and c >= 1 and c <= self.cols
end

function Board:get(r, c)
    if not self:inBounds(r, c) then return nil end
    return self.grid[r][c]
end

function Board:set(r, c, piece)
    if not self:inBounds(r, c) then return end
    self.grid[r][c] = piece
end

function Board:countPieces(team)
    local total = 0
    for r = 1, self.rows do
        for c = 1, self.cols do
            local p = self.grid[r][c]
            if p and p.team == team then
                total = total + 1
            end
        end
    end
    return total
end

-- Spawns `count` pawns on a given row, random unique columns.
function Board:spawnPawnsOnRow(row, team, count, createPieceFn)
    local used = {}
    local placed = 0

    while placed < count do
        local col = love.math.random(1, self.cols)
        if not used[col] then
            used[col] = true
            self.grid[row][col] = createPieceFn("pawn", team)
            placed = placed + 1
        end
    end
end

return Board

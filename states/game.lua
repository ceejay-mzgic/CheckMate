-- states/game.lua
local Board  = require("systems.board")
local Moves  = require("systems.moves")
local AI     = require("systems.ai")
local Rounds = require("systems.rounds")

local game = {}
game.__index = game

function game:new(stateManager)
    local self = setmetatable({}, game)
    self.stateManager = stateManager

    -- Board settings
    self.rows = 5
    self.cols = 5
    self.tileSize = 120
    self.boardOffsetX = 0
    self.boardOffsetY = 0

    -- Core state
    self.board = Board.new(self.rows, self.cols)

    self.selected = nil
    self.legalMoves = {}

    self.currentTurn = "white"     -- player = white, enemy AI = black
    self.roundNumber = 1
    self.roundWinner = nil

    -- AI pacing (so it doesn't move instantly same frame)
    self.aiDelay = 0.35
    self.aiTimer = 0

    -- Fonts (create once)
    self.pieceFont = nil
    self.uiFont = nil

    return self
end

function game:enter()
    self:buildBoard()

    self.pieceFont = love.graphics.newFont(40)
    self.uiFont = love.graphics.newFont(18)

    self:startRound()
end

function game:buildBoard()
    local sw = love.graphics.getWidth()
    local sh = love.graphics.getHeight()

    local bw = self.cols * self.tileSize
    local bh = self.rows * self.tileSize

    self.boardOffsetX = (sw - bw) / 2
    self.boardOffsetY = (sh - bh) / 2
end

function game:createPiece(pieceType, team)
    return { type = pieceType, team = team, hasMoved = false }
end

-- Round system ------------------------------------------------------
function game:startRound()
    local roundState = Rounds.startRound(self.board, self.roundNumber, function(t, team)
        return self:createPiece(t, team)
    end)

    self.roundWinner = roundState.roundWinner
    self.currentTurn = "white"
    self.selected = nil
    self.legalMoves = {}
    self.aiTimer = 0
end

function game:checkRoundEnd()
    local whiteCount = self.board:countPieces("white")
    local blackCount = self.board:countPieces("black")

    if whiteCount == 0 then
        self.roundWinner = "black"
    elseif blackCount == 0 then
        self.roundWinner = "white"
    end
end

-- Move helpers ------------------------------------------------------
function game:getPieceLabel(piece)
    if piece.type == "pawn"   then return "P" end
    if piece.type == "rook"   then return "R" end
    if piece.type == "knight" then return "N" end
    if piece.type == "bishop" then return "B" end
    if piece.type == "queen"  then return "Q" end
    if piece.type == "king"   then return "K" end
    return "?"
end

function game:isLegalDestination(r, c)
    for _, m in ipairs(self.legalMoves) do
        if m.r == r and m.c == c then return true end
    end
    return false
end

function game:movePiece(fromR, fromC, toR, toC)
    local piece = self.board:get(fromR, fromC)
    if not piece then return end

    -- capture happens by overwrite
    self.board:set(fromR, fromC, nil)
    self.board:set(toR, toC, piece)
    piece.hasMoved = true

    -- pawn promotion
    if piece.type == "pawn" then
        if piece.team == "white" and toR == 1 then
            piece.type = "queen"
        elseif piece.team == "black" and toR == self.rows then
            piece.type = "queen"
        end
    end

    self.selected = nil
    self.legalMoves = {}

    -- switch turn
    self.currentTurn = (self.currentTurn == "white") and "black" or "white"

    -- check win/loss
    self:checkRoundEnd()
end

-- Update (AI turn) --------------------------------------------------
function game:update(dt)
    if self.roundWinner then return end

    if self.currentTurn == "black" then
        self.aiTimer = self.aiTimer + dt
        if self.aiTimer >= self.aiDelay then
            self.aiTimer = 0

            local fr, fc, tr, tc = AI.chooseRandomMove(self.board, Moves, "black")
            if fr then
                self:movePiece(fr, fc, tr, tc)
            else
                -- no legal moves: treat as loss (optional)
                self.roundWinner = "white"
            end
        end
    end
end

-- Draw --------------------------------------------------------------
function game:draw()
    love.graphics.clear(0.15, 0.15, 0.2)

    -- board
    for r = 1, self.rows do
        for c = 1, self.cols do
            local x = self.boardOffsetX + (c - 1) * self.tileSize
            local y = self.boardOffsetY + (r - 1) * self.tileSize

            if (r + c) % 2 == 0 then
                love.graphics.setColor(0.85, 0.85, 0.85)
            else
                love.graphics.setColor(0.3, 0.3, 0.3)
            end
            love.graphics.rectangle("fill", x, y, self.tileSize, self.tileSize)

            -- legal move highlight
            for _, m in ipairs(self.legalMoves) do
                if m.r == r and m.c == c then
                    love.graphics.setColor(0, 1, 0, 0.4)
                    love.graphics.rectangle("fill", x, y, self.tileSize, self.tileSize)
                    break
                end
            end

            -- selection border
            if self.selected and self.selected.r == r and self.selected.c == c then
                love.graphics.setColor(1, 0, 0)
                love.graphics.setLineWidth(4)
                love.graphics.rectangle("line", x, y, self.tileSize, self.tileSize, 6)
            end

            -- piece
            local piece = self.board:get(r, c)
            if piece then
                local label = self:getPieceLabel(piece)
                if piece.team == "white" then
                    love.graphics.setColor(1, 1, 1)
                else
                    love.graphics.setColor(0.1, 0.1, 0.1)
                end

                love.graphics.setFont(self.pieceFont)
                local tw = self.pieceFont:getWidth(label)
                local th = self.pieceFont:getHeight()

                love.graphics.print(
                    label,
                    x + (self.tileSize - tw) / 2,
                    y + (self.tileSize - th) / 2
                )
            end
        end
    end

    -- UI
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(self.uiFont)

    love.graphics.print("Round: " .. tostring(self.roundNumber), 20, 20)

    if self.roundWinner then
        love.graphics.print("ROUND OVER - Winner: " .. self.roundWinner, 20, 45)
        love.graphics.print("Click anywhere to start next round", 20, 65)
    else
        love.graphics.print("Current turn: " .. self.currentTurn, 20, 45)
        love.graphics.print("ESC: back to menu", 20, 65)
        if self.currentTurn == "black" then
            love.graphics.print("Enemy thinking...", 20, 85)
        end
    end
end

-- Input -------------------------------------------------------------
function game:mousepressed(x, y, button)
    if button ~= 1 then return end

    -- next round click
    if self.roundWinner then
        self.roundNumber = self.roundNumber + 1
        self:startRound()
        return
    end

    -- lock player input during AI turn
    if self.currentTurn ~= "white" then return end

    local r = math.floor((y - self.boardOffsetY) / self.tileSize) + 1
    local c = math.floor((x - self.boardOffsetX) / self.tileSize) + 1
    if not self.board:inBounds(r, c) then return end

    local clickedPiece = self.board:get(r, c)

    if self.selected then
        -- deselect
        if self.selected.r == r and self.selected.c == c then
            self.selected = nil
            self.legalMoves = {}
            return
        end

        -- reselect another own piece
        if clickedPiece and clickedPiece.team == "white" then
            self.selected = { r = r, c = c }
            self.legalMoves = Moves.getLegalMoves(self.board, r, c)
            return
        end

        -- move if legal
        if self:isLegalDestination(r, c) then
            self:movePiece(self.selected.r, self.selected.c, r, c)
            return
        end

        -- invalid -> clear
        self.selected = nil
        self.legalMoves = {}
        return
    else
        -- select only own pieces
        if clickedPiece and clickedPiece.team == "white" then
            self.selected = { r = r, c = c }
            self.legalMoves = Moves.getLegalMoves(self.board, r, c)
        end
    end
end

return game

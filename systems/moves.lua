-- systems/moves.lua
local Moves = {}

local function addMove(list, r, c)
    table.insert(list, { r = r, c = c })
end

function Moves.getLegalMoves(board, r, c)
    local piece = board:get(r, c)
    if not piece then return {} end

    if piece.type == "pawn"   then return Moves.getPawnMoves(board, r, c, piece) end
    if piece.type == "rook"   then return Moves.getRookMoves(board, r, c, piece) end
    if piece.type == "bishop" then return Moves.getBishopMoves(board, r, c, piece) end
    if piece.type == "queen"  then return Moves.getQueenMoves(board, r, c, piece) end
    if piece.type == "knight" then return Moves.getKnightMoves(board, r, c, piece) end
    if piece.type == "king"   then return Moves.getKingMoves(board, r, c, piece) end

    return {}
end

-- Pawn (simplified): 1 forward if empty, diagonal capture, promotion handled elsewhere
function Moves.getPawnMoves(board, r, c, piece)
    local moves = {}
    local dir = (piece.team == "white") and -1 or 1
    local forwardR = r + dir

    -- forward
    if board:inBounds(forwardR, c) and board:get(forwardR, c) == nil then
        addMove(moves, forwardR, c)
    end

    -- diagonal captures
    for _, dc in ipairs({-1, 1}) do
        local rr = r + dir
        local cc = c + dc
        if board:inBounds(rr, cc) then
            local target = board:get(rr, cc)
            if target and target.team ~= piece.team then
                addMove(moves, rr, cc)
            end
        end
    end

    return moves
end

-- Rook
function Moves.getRookMoves(board, r, c, piece)
    local moves = {}

    -- up
    for rr = r - 1, 1, -1 do
        local target = board:get(rr, c)
        if not target then
            addMove(moves, rr, c)
        else
            if target.team ~= piece.team then addMove(moves, rr, c) end
            break
        end
    end

    -- down
    for rr = r + 1, board.rows do
        local target = board:get(rr, c)
        if not target then
            addMove(moves, rr, c)
        else
            if target.team ~= piece.team then addMove(moves, rr, c) end
            break
        end
    end

    -- left
    for cc = c - 1, 1, -1 do
        local target = board:get(r, cc)
        if not target then
            addMove(moves, r, cc)
        else
            if target.team ~= piece.team then addMove(moves, r, cc) end
            break
        end
    end

    -- right
    for cc = c + 1, board.cols do
        local target = board:get(r, cc)
        if not target then
            addMove(moves, r, cc)
        else
            if target.team ~= piece.team then addMove(moves, r, cc) end
            break
        end
    end

    return moves
end

-- Bishop
function Moves.getBishopMoves(board, r, c, piece)
    local moves = {}

    local function scan(dr, dc)
        local rr, cc = r + dr, c + dc
        while board:inBounds(rr, cc) do
            local target = board:get(rr, cc)
            if not target then
                addMove(moves, rr, cc)
            else
                if target.team ~= piece.team then addMove(moves, rr, cc) end
                break
            end
            rr, cc = rr + dr, cc + dc
        end
    end

    scan(-1, -1)
    scan(-1,  1)
    scan( 1, -1)
    scan( 1,  1)

    return moves
end

-- Queen
function Moves.getQueenMoves(board, r, c, piece)
    local moves = Moves.getRookMoves(board, r, c, piece)
    local diag  = Moves.getBishopMoves(board, r, c, piece)
    for _, m in ipairs(diag) do table.insert(moves, m) end
    return moves
end

-- Knight
function Moves.getKnightMoves(board, r, c, piece)
    local moves = {}
    local offsets = {
        {-2,-1},{-2, 1},
        {-1,-2},{-1, 2},
        { 1,-2},{ 1, 2},
        { 2,-1},{ 2, 1},
    }

    for _, off in ipairs(offsets) do
        local rr = r + off[1]
        local cc = c + off[2]
        if board:inBounds(rr, cc) then
            local target = board:get(rr, cc)
            if not target or target.team ~= piece.team then
                addMove(moves, rr, cc)
            end
        end
    end

    return moves
end

-- King (no check detection)
function Moves.getKingMoves(board, r, c, piece)
    local moves = {}
    for dr = -1, 1 do
        for dc = -1, 1 do
            if not (dr == 0 and dc == 0) then
                local rr = r + dr
                local cc = c + dc
                if board:inBounds(rr, cc) then
                    local target = board:get(rr, cc)
                    if not target or target.team ~= piece.team then
                        addMove(moves, rr, cc)
                    end
                end
            end
        end
    end
    return moves
end

return Moves

-- systems/ai.lua
local AI = {}

-- Returns: fromR, fromC, toR, toC OR nil if no moves.
function AI.chooseRandomMove(board, movesModule, team)
    local movable = {}

    for r = 1, board.rows do
        for c = 1, board.cols do
            local p = board:get(r, c)
            if p and p.team == team then
                local legal = movesModule.getLegalMoves(board, r, c)
                if #legal > 0 then
                    table.insert(movable, { r = r, c = c, legal = legal })
                end
            end
        end
    end

    if #movable == 0 then
        return nil
    end

    local pick = movable[love.math.random(1, #movable)]
    local dest = pick.legal[love.math.random(1, #pick.legal)]

    return pick.r, pick.c, dest.r, dest.c
end

return AI

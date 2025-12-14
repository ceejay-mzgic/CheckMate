-- systems/rounds.lua
local Rounds = {}

function Rounds.startRound(board, roundNumber, createPieceFn)
    board:clear()

    -- Prototype 4 rule (your current rule): 3 pawns each, no kings/queens placed.
    -- Kept simple so AI + turn system are the focus.
    board:spawnPawnsOnRow(4, "white", 3, createPieceFn)
    board:spawnPawnsOnRow(2, "black", 3, createPieceFn)

    return {
        roundNumber = roundNumber,
        roundWinner = nil
    }
end

return Rounds

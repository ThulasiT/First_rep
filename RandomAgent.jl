type RandomAgent <: AgentBase
    agentId::UInt8              # This is mandatory field
    lastMove::Position
    lastBoardState::Board

    function RandomAgent( )
        error( "You must specify an agent id while creating agent as RandomAgent(<id>)" )
    end

    function RandomAgent( id::Int )
        new( UInt8(id), Position(), Board() )
    end
end

# Return must a move
function getMove( agent::RandomAgent, b::Board )

    # print( "Agent#", agent.agentId, " playing ", b)

    pos = Position()
    validMove = false

    while !validMove        # Run untill we find a free position in board
        pos = Position( UInt8(rand(1:3)), UInt8(rand(1:3)) )
        validMove = isFree( b, pos )
    end

    # Save this board position
    agent.lastBoardState = Board(b)
    agent.lastMove = pos

    return pos
end

function finalize( agent::RandomAgent, b::Board, r::Number )
    # r - reward
    # print( "Finalizing agent#", agent.agentId, "  with ", b, " and r = ", r, "\n" );

    # Update agent state based on b and r

    # Put code for finalizing the episode
    agent.lastMove = Position()
    agent.lastBoardState = Board()
end

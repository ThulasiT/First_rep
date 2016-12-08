import Base.print

# include( "AgentBase.jl" )

type Board
    state::Array{Int8,2}

    # Initialises a board to blank
    function Board()
        # Initialises all positions to blank
        new( zeros(Int8,3,3) )
    end

    # Construct a board from another
    function Board( _board::Board )
        # Copies state from given board
        new( _board.state )
    end

    # Construct a board from a 3x3 array
    function Board( _state::Array{Int,2} )
        size(_state) == (3,3) ?     # Check whether a 3x3 board
        new( _state ):              # If yes, create with _state
        error( "Initializing array should be 3x3 matrix" );     # Else raise an error
    end
end

function print( io::IO, b::Board )
    print( io, "Board State: \n" )
    print( io, "    Player 1 : X\n" )
    print( io, "    Player 2 : O\n" )
    for i = 1:3
        print( io, "    " )
        for j = 1:3
            b.state[i,j] == 0 ?
                print( "- " ):
                b.state[i,j] == 1 ?
                    print( io, "X " ):
                    print( io, "O " )
        end
        print( io, "\n" )
    end
end

function isFree( b::Board, p::Position )
    return b.state[p.x,p.y] == 0
end

function gameOver( b::Board )
    # Check for terminal state in board, returns 0 if
    if b.state[1,1]==b.state[1,2]==b.state[1,3]!=0 ||
       b.state[2,1]==b.state[2,2]==b.state[2,3]!=0 ||
       b.state[3,1]==b.state[3,2]==b.state[3,3]!=0 ||
       b.state[1,1]==b.state[2,1]==b.state[3,1]!=0 ||
       b.state[1,2]==b.state[2,2]==b.state[3,2]!=0 ||
       b.state[1,3]==b.state[2,3]==b.state[3,3]!=0 ||
       b.state[1,1]==b.state[2,2]==b.state[3,3]!=0 ||
       b.state[1,3]==b.state[2,2]==b.state[3,1]!=0 ||
       sum(b.state.==0) == 0    # no move possible
        return true
    else
        return false
    end
end

function updateBoard( b::Board, p::Position, a::AgentBase )
    b.state[p.x,p.y] = a.agentId
end

# Checks and return who won - 0 if the board is a draw
function getWinner( b::Board )
    if b.state[1,1]==b.state[1,2]==b.state[1,3] ||
       b.state[1,1]==b.state[2,1]==b.state[3,1]
        return b.state[1,1]
    elseif b.state[1,3]==b.state[2,3]==b.state[3,3] ||
            b.state[3,1]==b.state[3,2]==b.state[3,3]
        return b.state[3,3]
    elseif b.state[1,1]==b.state[2,2]==b.state[3,3] ||
            b.state[1,2]==b.state[2,2]==b.state[3,2] ||
            b.state[1,3]==b.state[2,2]==b.state[3,1] ||
            b.state[2,1]==b.state[2,2]==b.state[2,3]
        return b.state[2,2]
    else
        return 0
    end
end

# Program to play tic tac toe

workspace()     # To clear all previous imports

include( "AgentBase.jl" )
include( "Board.jl" )
include( "RandomAgent.jl" )
include( "SarsaAgent.jl" )

#################### Main Program ###############
counter_winner1 = 0
counter_winner2 = 0
counter_draw    = 0

p1 = SarsaAgent( 1 )
p2 = RandomAgent( 2 )

for gameId = 1:10000
    gameBoard = Board()

    roundCounter = 1;

    gameEnded = false

    player = rand(1:2)==1?p1:p2         # Randomly select a starting player

    # print( "-------- START OF GAME --------\n" )
    # Play untill nobody wins or no move possible
    while ~gameOver(gameBoard)
        # print( "Step#", roundCounter, ": " )

        nxtMove = getMove( player, gameBoard )

        # print( "Player#", player.agentId, " playing at ", nxtMove, "\n" )
        updateBoard( gameBoard, nxtMove, player )
        # print( gameBoard )

        # Swicth to next player
        player = (player==p1)?p2:p1

        roundCounter += 1
    end

    # Find the winner and give reward - both loss and draw gets -1
    # print( gameBoard )
    winner = getWinner( gameBoard )
    # print( "Winner : ", winner, "\n" )
    finalize( p1, gameBoard, (winner==1)?10:(winner==0)?0:-10 )
    finalize( p2, gameBoard, (winner==2)?10:(winner==0)?0:-10 )

    # Update counters
    if winner==1
        counter_winner1 += 1
    elseif winner==2
        counter_winner2 += 1
    else
        counter_draw += 1
    end
end

print( "w1: ", counter_winner1, "\n",
       "w2: ", counter_winner2, "\n",
       "draw: ", counter_draw )

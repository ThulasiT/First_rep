type SarsaAgent <: AgentBase
    agentId::UInt8              # This is mandatory field
    lastMove::Position
    lastBoardState::Board
    Qval::Array{Float64,2}

    function SarsaAgent( )
        error( "You must specify an agent id while creating agent as SarsaAgent(<id>)" )
    end

    function SarsaAgent( id::Int )
        new( UInt8(id), Position(), Board(), zeros(19683,9) )
    end
end

# Return must a move
function getMove( agent::SarsaAgent, b::Board )

    # print( "Agent#", agent.agentId, " playing ", b)

    pos = Position()

    CurStateIn=getState(b)
    PrevStateIn=getState(agent.lastBoardState)
    PrevAction=getPosIndex(agent.lastMove)

    validMove = []
    for i=1:3
      for j=1:3
            cur_pos=Position( UInt8(i), UInt8(j) )
            if isFree(b,cur_pos)
              move=getPosIndex(cur_pos)
              validMove =push!(validMove,move)
            end
      end
    end

    #Parameters
    epsilon=0.01
    #alpha=0.9 Learning rate
    gamma= 0.9 #Discount factor

    #Choosing a random Number
    rno=rand()
    #Epsilon greedy action selection
    if rno > epsilon #Pick greedy action
      action= indmax( [ agent.Qval[CurStateIn,i] for i in validMove ] )
      action=validMove[action]
    else
      temp=rand(1:length(validMove))
      action=validMove[temp]
    end
    b.state[action]=agent.agentId

    pos=getPos(action)

    #SARSA Update
    agent.Qval[PrevStateIn,PrevAction] += 0.99 *(-10 + gamma*agent.Qval[CurStateIn,action] - agent.Qval[PrevStateIn,PrevAction] )

    # Save this board position
    agent.lastBoardState = Board(b)
    agent.lastMove = pos

    return pos
end

function finalize( agent::SarsaAgent, b::Board, r::Number )
    # r - reward
    # print( "Finalizing agent#", agent.agentId, "  with ", b, " and r = ", r, "\n" );

    # Update agent state based on b and r
    PrevStateIn=getState(agent.lastBoardState)
    PrevAction=getPosIndex(agent.lastMove)
    agent.Qval[PrevStateIn,PrevAction] += 0.99 *(r - agent.Qval[PrevStateIn,PrevAction] )

    # Put code for finalizing the episode
    agent.lastMove = Position()
    agent.lastBoardState = Board()
end

function getPosIndex(pos::Position)
  move=(pos.x)+((pos.y-1)*3)

  return move
end

function getState(b::Board)
  s=0
  for i=1:9
    s=s+(b.state[i]*(3^(i-1)))
  end

  return s+1
end

function getPos(a::Number)
  pos=Position()
  pos.x=(a%3)
  if pos.x==0
    pos.x=3
  end
  pos.y= div(a-1,3)+1
  return pos
end

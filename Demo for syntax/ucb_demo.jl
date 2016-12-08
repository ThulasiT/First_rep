# Demo program for UCB1 algorithm
# This is written to be ran in Atom julia client

using Gadfly
using Distributions
using Colors

begin
    # Define number of arms for the bandit
    noOfArms = 4
    # Create reward distribution - p_i for each arm
    p = rand( noOfArms )
    arms = [ Bernoulli(p[i]) for i in 1:noOfArms ]
    plot( x = 1:noOfArms, y = p, Geom.bar, Theme(bar_spacing=3mm),
          Guide.xlabel("Arm Id"), Guide.ylabel("p"), Guide.title("Arm Reward distribution") )         # See the reward distribution
end
print( "Reward Distribution: ", [@sprintf("%4.3f ",p[i]) for i=1:noOfArms]... )

################################# UCB Algorithm - Step by Step #########################
# Initialization
begin
    t = 0    # Timestep
    x_bar = zeros( noOfArms ) # Mean reward
    ni = zeros( noOfArms )     # number of times each arm is played
    ucbIdx = zeros( noOfArms )     # UCB Index

    # First step - play all arms once
    for i in 1:noOfArms
        t = t + 1
        r = rand( arms[i] )                 # Get this arm reward
        x_bar[i] = ((ni[i]*x_bar[i]) + r )/(ni[i]+1)    # update average reward from this arm
        ni[i] = ni[i] + 1
    end

    # Update indices for all arms
    ucbIdx = x_bar + sqrt(2log(t)./ni)

    plot(
        layer( x=1:noOfArms, y=x_bar,  Geom.bar, Theme(bar_spacing=4mm,default_color=colorant"#1874CD" )),
        layer( x=1:noOfArms, y=ucbIdx, Geom.bar, Theme(bar_spacing=2mm,default_color=colorant"#67C8FF" )),
        Guide.xlabel( "Arm Id" ),
        Guide.manual_color_key("Legend",["Avg. Reward","UCB Index"],[colorant"#1874CD",colorant"#67C8FF"]),
        Guide.title( @sprintf("t = %d",t) )
    )
end

# Print Game Status
print( @sprintf("t = %3d: ",t),
       "\n    Avg. Reward     : ", [@sprintf("%4.3f ",x_bar[i]) for i=1:noOfArms]...,
       "\n    Number of plays : ", [@sprintf("%5d ",ni[i]) for i=1:noOfArms]...,
       "\n    UCB Index       : ", [@sprintf("%4.3f ",ucbIdx[i]) for i=1:noOfArms]... )

# From now, play the arm with highest index
begin
    i = indmax( ucbIdx )        # Pick arm to play
    r = rand( arms[i] )         # Get reward of current play
    x_bar[i] = ((ni[i]*x_bar[i])+r)/(ni[i]+1)       # Update avg.value of arm
    ni[i] = ni[i] + 1           # Update number of plays of arm

    # Print curret pull result
    print( "    Current Arm    : ", i, "\n",
           "    Current Reward : ", r, "\n" )

    t = t + 1
    ucbIdx = x_bar + sqrt(2log(t)./ni)

    # Print Game state
    print( @sprintf("t = %3d: ",t),
           "\n    Avg. Reward     : ", [@sprintf("%4.3f ",x_bar[i]) for i=1:noOfArms]...,
           "\n    Number of plays : ", [@sprintf("%5d ",ni[i]) for i=1:noOfArms]...,
           "\n    UCB Index       : ", [@sprintf("%4.3f ",ucbIdx[i]) for i=1:noOfArms]... )

    # Plot avg reward and ucb indices
    plot(
        layer( x=1:noOfArms, y=p,      Geom.bar, Theme(bar_spacing=6mm, default_color=colorant"#4293DD") ),
        layer( x=1:noOfArms, y=x_bar,  Geom.bar, Theme(bar_spacing=4mm, default_color=colorant"#1874CD") ),
        layer( x=1:noOfArms, y=ucbIdx, Geom.bar, Theme(bar_spacing=2mm, default_color=colorant"#67C8FF") ),
        # Theme( background_color=colorant"#333" ),
        Guide.xlabel( "Arm Id" ),
        Guide.manual_color_key("Legend",
                                       [ "Avg. Reward", "UCB Index", "Actual Reward" ],
                                       [ colorant"#1874CD", colorant"#67C8FF", colorant"#4293DD" ] ),
        Guide.title( @sprintf("t = %d",t) ),
        Coord.Cartesian(ymin=0.0,ymax=3.5)
    )
end


begin
    simulationSteps = 1000
    # Run the algorithm from first
    valueEvolution = zeros( noOfArms, 0 )       # To store the evolution of arm values
    # Initialize - sample from all arms once
    t       = 0
    x_bar   = zeros( noOfArms )
    ni      = zeros( noOfArms )
    ucbIdx  = zeros( noOfArms )
    for i = 1:noOfArms
        r           = rand( arms[i] )
        x_bar[i]    = ((ni[i]*x_bar[i])+r)/(ni[i]+1)    # Update avg.value of arm
        ni[i]       = ni[i] + 1                         # Update number of plays of arm
        t           = t + 1
        ucbIdx = x_bar + sqrt(2log(t)./ni)              # Update UCB index
        valueEvolution = hcat( valueEvolution, ucbIdx )
    end
    # Now run for some steps
    while t < simulationSteps
        i           = indmax( ucbIdx )                  # Pick arm to play
        r           = rand( arms[i] )                   # Get reward of current play
        x_bar[i]    = ((ni[i]*x_bar[i])+r)/(ni[i]+1)    # Update avg.value of arm
        ni[i]       = ni[i] + 1                         # Update number of plays of arm
        t           = t + 1
        ucbIdx = x_bar + sqrt(2log(t)./ni)
        valueEvolution = hcat( valueEvolution, ucbIdx )
    end

    # Plot the evolution
    penColors = distinguishable_colors( 2*noOfArms)[2:2:end]
    plot(
        [ layer( x = 1:simulationSteps, y = valueEvolution[i,:], Geom.line,
                        Theme(default_color=penColors[i]) ) for i = 1:noOfArms ]...,
        Guide.xlabel( "time steps" ),
        Guide.ylabel( "Arm Value" ),
        Guide.title( "Value Evolution of Arm Value" ),
        Guide.manual_color_key( "Arms", [@sprintf("#%d",i) for i=1:noOfArms], penColors )
    )
end

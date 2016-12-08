import Base.print

type Position
    x::Int8
    y::Int8

    # Initialises
    function Position()
        new( 1, 1 )
    end

    function Position( _x::UInt8, _y::UInt8 )
        new( _x, _y )
    end
end

function print( io::IO, p::Position )
    print( io, "(", p.x, ",", p.y , ")" )
end

abstract AgentBase

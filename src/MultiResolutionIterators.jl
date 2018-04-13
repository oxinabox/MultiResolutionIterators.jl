module MultiResolutionIterators
export ALL_LEVELS, full_collect, flatten_levels, collect_levels

include("core.jl")
include("namedlevels.jl")

const ALL_LEVELS=0:typemax(Int)
include("functionality.jl")
 
end # module

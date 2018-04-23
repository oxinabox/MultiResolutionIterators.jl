module MultiResolutionIterators
using IterTools: imap
export ALL_LEVELS, lvls,
    flatten_levels, join_levels,
    consolidate_levels, full_consolidate, consolidate


include("basic_functions.jl")
include("core.jl")
include("namedlevels.jl")

const ALL_LEVELS=0:typemax(Int)
include("functionality.jl")

end # module

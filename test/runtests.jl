using MultiResolutionIterators
using Base.Test


names = ["basic_functions", "functionality", "namedlevels", "demoscript", "customisability"]

@testset "$name" for name in names
    include("test_" * name *".jl")
end

using MultiResolutionIterators
using Base.Test


names = ["basic_functions", "functionality", "namedlevels", "demoscript"]

@testset "$name" for name in names
    include("test_" * name *".jl")
end

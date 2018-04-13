using MultiResolutionIterators
using Base.Test


names = ["functionality", "namedlevels", "demoscript"]

@testset "$name" for name in names
    include("test_" * name *".jl")
end

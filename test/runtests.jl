using MultiResolutionIterators
using Base.Test


names = ["functionality"]

@testset "$name" for name in names
    include("test_" * name *".jl")
end

#= Tools for working with levels by name =#

"""
    levelname_map(indexer)::Vector{Pair{Symbol, Int}}

This should be overloaded by any indexer for a MultiResolutionIterator
To map from level names to numbers,

An indexer could be a type that represents a Corpus for example.
It could be the top level of the MultiResolutionIterator itself,
if that has a unique type.
But it doesn't have to be. It just needs to be a handle we can dispatch on

The returned vector maps Named levels to their numbers
Multiple names can be given to the name nmbered level (Many to One)
"""
function levelname_map end


exclude_levels(indexer) = unique(last.(levelname_map(indexer)))

function exclude_levels(indexer, nums::Vararg{<:Integer})
    all_levels = exclude_levels(indexer)
    setdiff(all_levels, nums)
    # all the levels, except the ones we are excluding
end

function exclude_levels(indexer, names::Vararg{Symbol})
    exclude_levels(indexer, include_levels(indexer, names...)...)
end

include_levels(indexer) = Int[]

include_levels(indexer, nums::Vararg{<:Integer}) = nums

function include_levels(indexer, names::Vararg{Symbol})
    inds = findin(first.(levelname_map(indexer)), names)
    level_nums = last.(levelname_map(indexer)[inds])
    include_levels(indexer, level_nums...)
end

############################################
#=               API                      =#

lvls(indexer, args...) = include_levels(indexer, args...)

Base.:!(::typeof(lvls)) = (indexer, args...) -> exclude_levels(indexer, args...)




#

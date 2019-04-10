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

# include the levels
lvls(indexer) = Int[]
lvls(indexer, nums::Vararg{<:Integer}) = nums
function lvls(indexer, names::Vararg{Symbol})
    name_set = first.(levelname_map(indexer))
    num_set = last.(levelname_map(indexer))
    map(names) do name
        ind = something(findfirst(isequal(name), name_set), 0)
        num_set[ind]
    end
end

function lvls(indexer, named_level_ops::Dict)
    nums = lvls(indexer, keys(named_level_ops)...)
    Dict(zip(nums, values(named_level_ops)))
end


################
# exclude3 the levels using `(!lvls)(args...)`

not_lvls(indexer) = unique(last.(levelname_map(indexer)))

function not_lvls(indexer, nums::Vararg{<:Integer})
    all_levels = (!lvls)(indexer)
    setdiff(all_levels, nums)
    # all the levels, except the ones we are excluding
end

function not_lvls(indexer, names::Vararg{Symbol})
    (!lvls)(indexer, lvls(indexer, names...)...)
end

# make `(!lvls)`  the same as `not_lvls`
(Base.:!(::typeof(lvls))) = not_lvls

#

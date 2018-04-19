using Base.Test
using MultiResolutionIterators

struct Document{T}
    content::T
end

Base.start(doc::Document)=Base.start(doc.content)
Base.next(doc::Document, state)=Base.next(doc.content, state)
Base.done(doc::Document, state)=Base.done(doc.content, state)


function MultiResolutionIterators.consolidate(aiter::Document)
    Document(consolidate(aiter.content))
end

function MultiResolutionIterators.apply(ff, aiter::Document)
    Document(MultiResolutionIterators.apply(ff, aiter.content))
end

animal_info = [
    Document([["Turtles", "are", "reptiles", "."],
     ["They", "have", "shells", "."],
     ["They", "live", "in", "the", "water", "."]]),
    Document([["Cats", "are", "mammals", "."],
     ["They", "live", "on", "the", "internet", "."]])
    ]

# Declare an indexer.
struct AnimalTextIndexer end;

# Overload `levelname_map` this so it knows the name mapping
MultiResolutionIterators.levelname_map(::AnimalTextIndexer) = [
    :documents=>1,
    :sentences=>2,
    :words=>3, :tokens=>3, # can have multiple aliases for same level
    :characters=>4 # As characters themselves are not iterable this name/level has little effect
]
indexer = AnimalTextIndexer();

# Merge all sentences
@test merge_levels(animal_info, lvls(indexer, :sentences))|>full_consolidate isa Vector{Document}
@test full_consolidate(merge_levels(animal_info, lvls(indexer, :sentences))) isa
    Vector{Document{Vector{Vector{String}}}}

# I.e keep documents, and words
@test full_consolidate(merge_levels(animal_info, (!lvls)(indexer, :words, :documents))) isa
    Vector{Document{Vector{Vector{String}}}}

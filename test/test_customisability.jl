using MultiResolutionIterators
using Test

struct Document{T}
    content::T
end

Base.iterate(doc::Document)=iterate(doc.content)
Base.iterate(doc::Document, state)=iterate(doc.content, state)

Base.length(doc::Document)=Base.length(doc.content)

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

@testset "Consolidate" begin
    @test consolidate(animal_info[1]) |> typeof <: Document
    @test consolidate_levels(animal_info[1],1) |> typeof <: Document
    @test full_consolidate(animal_info[1]) |> typeof <: Document
end

@testset "Demo tests" begin
    # Merge all sentences
    docs_of_words1 =  full_consolidate(flatten_levels(animal_info, lvls(indexer, :sentences)))
    @test typeof(docs_of_words1) == Vector{Document{Vector{String}}}

    # I.e keep documents, and words
    docs_of_words2 = full_consolidate(flatten_levels(animal_info, (!lvls)(indexer, :words, :documents)))
    @test typeof(docs_of_words2) == Vector{Document{Vector{String}}}
    @test collect(docs_of_words2[1]) == collect(docs_of_words1[1])
    @test collect(docs_of_words2[2]) == collect(docs_of_words1[2])
end

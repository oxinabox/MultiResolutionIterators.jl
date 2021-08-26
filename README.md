# MultiResolutionIterators
[![Build status](https://ci.appveyor.com/api/projects/status/truta8xkt9e2k5mi/branch/master?svg=true)](https://ci.appveyor.com/project/oxinabox/multiresolutioniterators-jl/branch/master)

There are many different ways to look at text corpora.
The true structure of a corpus might be:
 - **Corpus**
 - made up of: **Documents**
 - made up of: **Paragraphs**
 - made up of: **Sentences**
 - made up of: **Words**
 - made up of: **Characters**

Very few people want to consider it at that level.
 - Someone working in **Information Retrieval** might want to consider the corpus as **Corpus made up of Documents made up of Words**.
 - Someone working on **Language Modeling** might want to consider **Corpus made up of Words**
 - Someone working on **Parsing** might want to consider **Corpus made up Sentences made up of Words**.
 - Someone training a **Char-RNN** might want to consider **Corpus made up of Characters**.

 This package lets you better work with iterators of iterators to allow them to be flattened and viewed at different levels.


## Operations

### `consolidate`
This is a variation on `collect`.
It only promises the returned result will be indexable,
not that it will be a `Vector`.
`consolidate`ing iterators with an `eltype` of `Char`, will give you Strings, which for most of our uses is better than `Vector{Char}`.
Beyond its use for `consolidate_levels` it is also useful as a nonleveled operation as it may be faster than convert, and/or make use of costomized behavour from  overloading `apply`, (see [Customizing Behavour](#customizing-behavour)).

### `consolidate_levels` & `full_consolidate`
This converts the given levels from iterators to `Vector`s.
The most useful is likely `consolidate_levels(iter, ALL_LEVELS)` which we export under the alias `full_consolidate`.


### `flatten_levels`

This is the levelled version of flatten.
`flatten_levels(iter, 1)` is the same as `Base.Iterators.flatten(iter)`.
`flatten_levels(iter, 2)` is the same as `Base.Iterators.flatten.(iter)` (assuming iter is Vector or similar)
`flatten_levels(iter, 1:2)` is the same as `Base.Iterators.flatten(Base.Iterators.flatten.(iter))`
`flatten_levels(iter, ALL_LEVELS)` results in a fully flat output.


### `join_levels`
This is a generalization of `join(strings, delim)`
Pass in a dictionary from levels to the character/string to be used to join that level.
e.g. `join_levels(animal_info, Dict(2=>"\n", 3=>" "))`

## Customizing Behavior
### Controlling return type of applying functions to levels/elements by overloading `apply`
MultiResolutionIterators will by default destroy all types at all levels it touches,
because it needs to replace their iterators with new modified versions (from some operation happening far below).
To avoid that you can overload `MultiResolutionIterators.apply(f, xs::MyType)`,
which is the internal function that is used to apply `f` to `xs` -- it defaults to `f(xs)`.
You could overload it to `MultiResolutionIterators.apply(f, xs::MyType) = MyType(f(xs)` for example.

### Make named levels functionality work by defining a `levelname_map` for an Indexer.
To make `lvls` work to provide **named levels** functionality,
you need to define some type to be your indexer,
and overload `MultiResolutionIterators.levelname_map`
to return a vector of Pairs mapping your index (normally some symbol or a string, but could be anything, baring an Integer) to the integer that is the level number.

## Usage

A simple example we have a corpus, made of documents (on about turtles and one about cats).
The documents are made up of sentences, which are made up of words, which are made up of characters.

The basic usage is to specify levels to act on by directly specifing the number.
The more advances usage is to declare an **indexer**, then refer to the levels by **name**.


### Basic usage

```
julia> using MultiResolutionIterators

julia> animal_info = [
           [["Turtles", "are", "reptiles", "."],
            ["They", "have", "shells", "."],
            ["They", "live", "in", "the", "water", "."]],
           [["Cats", "are", "mammals", "."],
            ["They", "live", "on", "the", "internet", "."]]
           ]
2-element Array{Array{Array{String,1},1},1}:
 Array{String,1}[String["Turtles", "are", "reptiles", "."], String["They", "have", "shells", "."], String["They", "live", "in", "the", "water", "."]]
 Array{String,1}[String["Cats", "are", "mammals", "."], String["They", "live", "on", "the", "internet", "."]]

julia> # Get rid of document boundaries
       flatten_levels(animal_info, 1) |> full_consolidate
5-element Array{Array{String,1},1}:
 String["Turtles", "are", "reptiles", "."]
 String["They", "have", "shells", "."]
 String["They", "live", "in", "the", "water", "."]
 String["Cats", "are", "mammals", "."]
 String["They", "live", "on", "the", "internet", "."]

julia> # Get rid of sentence boundaries, so documents made up of words
       flatten_levels(animal_info, 2) |> full_consolidate
2-element Array{Array{String,1},1}:
 String["Turtles", "are", "reptiles", ".", "They", "have", "shells", ".", "They", "live", "in", "the", "water", "."]
 String["Cats", "are", "mammals", ".", "They", "live", "on", "the", "internet", "."]

julia> # Get rid of document and sentence boundries
       flatten_levels(animal_info, 1:2) |> full_consolidate
24-element Array{String,1}:
 "Turtles"
 "are"
 "reptiles"
 "."
 "They"
 "have"
 "shells"
 "."
 "They"
 "live"
 "in"
 "the"
 "water"
 "."
 "Cats"
 "are"
 "mammals"
 "."
 "They"
 "live"
 "on"
 "the"
 "internet"
 "."

julia> # Get rid of all boundaries, just a stream of characters
       flatten_levels(animal_info, ALL_LEVELS) |> full_consolidate
"Turtlesarereptiles.Theyhaveshells.Theyliveinthewater.Catsaremammals.Theyliveontheinternet."

julia> # Get rid of word boundaries so each document is a a stream of characters
       flatten_levels(animal_info, [1,3]) |> full_consolidate
5-element Array{String,1}:
 "Turtlesarereptiles."
 "Theyhaveshells."
 "Theyliveinthewater."
 "Catsaremammals."
 "Theyliveontheinternet."

julia> # Join all words using spaces, keep other structure
       join_levels(animal_info, Dict(3=>" ")) |> full_consolidate
2-element Array{Array{String,1},1}:
 String["Turtles are reptiles .", "They have shells .", "They live in the water ."]
 String["Cats are mammals .", "They live on the internet ."]
```


### Working with Named Levels

If we declare an indexer,
we can use `lvls(indexer, names...)` to select which level to include by name,
or `(!lvls)(indexer, names...)` to select which levels to exlude by name.
Using level numbers also works with `lvls` and `(!lvls)`.


```
julia> # Declare an indexer.
       struct AnimalTextIndexer end;

julia> # Overload `levelname_map` this so it knows the name mapping
       MultiResolutionIterators.levelname_map(::AnimalTextIndexer) = [
           :documents=>1,
           :sentences=>2,
           :words=>3, :tokens=>3, # can have multiple aliases for same level
           :characters=>4 # As characters themselves are not iterable this name/level has little effect
       ]

julia> indexer = AnimalTextIndexer();

julia> # Merge all sentences
       flatten_levels(animal_info, lvls(indexer, :sentences)) |> full_consolidate
2-element Array{Array{String,1},1}:
 String["Turtles", "are", "reptiles", ".", "They", "have", "shells", ".", "They", "live", "in", "the", "water", "."]
 String["Cats", "are", "mammals", ".", "They", "live", "on", "the", "internet", "."]

julia> # Merge everything **except** words
       flatten_levels(animal_info, (!lvls)(indexer, :words)) |> full_consolidate
24-element Array{String,1}:
 "Turtles"
 "are"
 "reptiles"
 "."
 "They"
 "have"
 "shells"
 "."
 "They"
 "live"
 "in"
 "the"
 "water"
 "."
 "Cats"
 "are"
 "mammals"
 "."
 "They"
 "live"
 "on"
 "the"
 "internet"
 "."

julia> # Merge everything **except** words and sentences flatten_levels(animal_info, (!lvls)(indexer, :words, :sentences)) |> full_consolidate

       # i.e. merge documents
       flatten_levels(animal_info, lvls(indexer, :documents)) |> full_consolidate
5-element Array{Array{String,1},1}:
 String["Turtles", "are", "reptiles", "."]
 String["They", "have", "shells", "."]
 String["They", "live", "in", "the", "water", "."]
 String["Cats", "are", "mammals", "."]
 String["They", "live", "on", "the", "internet", "."]

julia> # # Join all words using spaces, join all sentences with new lines, all documents with double new lines
       join_levels(animal_info,
        lvls(indexer,Dict(:words=>" ", :sentences=>"\n", :documents=>"\n---\n"))) |>
        full_consolidate |> print
Turtles are reptiles .
They have shells .
They live in the water .
---
Cats are mammals .
They live on the internet .
```

## See also

 - [AbstractTrees.jl](https://github.com/Keno/AbstractTrees.jl): An iterator of iterators of ... etc duck-types as an `AbstractTree` and will work with AbstractTrees.jl
 - [MultiScaleArrays.jl](https://github.com/JuliaDiffEq/MultiScaleArrays.jl): A loosely similar idea to this, but focused on `AbstractArrays`.

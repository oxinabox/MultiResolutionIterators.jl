# MultiResolutionIterators

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

### `merge_levels`

This is the levelled version of flatten.
`merge(iter, 1)` is the same as `Base.Iterators.flatten(iter)`.
`merge(iter, 2)` is the same as `Base.Iterators.flatten.(iter)` (assuming iter is Vector or similar)
`merge(iter, 1:2)` is the same as `Base.Iterators.flatten(Base.Iterators.flatten.(iter))`
`merge(iter, ALL_LEVELS)` results in a fully flat output.

### `collect_levels`
This converts the given levels from iterators to `Vector`s.
The most useful is likely `collect(iter, ALL_LEVELS)` which we export under the alias `full_collect`.

### `join_levels`
This is a generalization of `join(strings, delim)`
Pass in a dictionary from levels to the character to be used to join that level.


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
            ["They", "live", "in", "the", "water"]],
           [["Cats", "are", "mammals", "."],
            ["They", "live", "on", "the", "internet"]]
           ]
2-element Array{Array{Array{String,1},1},1}:
 Array{String,1}[String["Turtles", "are", "reptiles", "."], String["They", "have", "shells", "."], String["They", "live", "in", "the", "water"]]
 Array{String,1}[String["Cats", "are", "mammals", "."], String["They", "live", "on", "the", "internet"]]

julia> # Get rid of document boundaries
       merge_levels(animal_info, 1) |> full_collect
5-element Array{Array{String,1},1}:
 String["Turtles", "are", "reptiles", "."]
 String["They", "have", "shells", "."]
 String["They", "live", "in", "the", "water"]
 String["Cats", "are", "mammals", "."]
 String["They", "live", "on", "the", "internet"]

julia> # Get rid of sentence boundaries, so documents made up of words
       merge_levels(animal_info, 2) |> full_collect
2-element Array{Array{String,1},1}:
 String["Turtles", "are", "reptiles", ".", "They", "have", "shells", ".", "They", "live", "in", "the", "water"]
 String["Cats", "are", "mammals", ".", "They", "live", "on", "the", "internet"]

julia> # Get rid of document and sentence boundaries
       merge_levels(animal_info, 1:2) |> full_collect
22-element Array{String,1}:
 "Turtles"
 "are"
 "reptiles"
 "."
 "They"
 "have"
 "shells"
 ⋮
 "."
 "They"
 "live"
 "on"
 "the"
 "internet"

julia> # Get rid of all boundaries, just a stream of characters
       merge_levels(animal_info, ALL_LEVELS) |> full_collect
88-element Array{Char,1}:
 'T'
 'u'
 'r'
 't'
 'l'
 'e'
 's'
 ⋮
 't'
 'e'
 'r'
 'n'
 'e'
 't'

julia> # Get rid of word boundaries so each document is a a stream of characters
       merge_levels(animal_info, [1,3]) |> full_collect
5-element Array{Array{Char,1},1}:
 ['T', 'u', 'r', 't', 'l', 'e', 's', 'a', 'r', 'e', 'r', 'e', 'p', 't', 'i', 'l', 'e', 's', '.']
 ['T', 'h', 'e', 'y', 'h', 'a', 'v', 'e', 's', 'h', 'e', 'l', 'l', 's', '.']
 ['T', 'h', 'e', 'y', 'l', 'i', 'v', 'e', 'i', 'n', 't', 'h', 'e', 'w', 'a', 't', 'e', 'r']
 ['C', 'a', 't', 's', 'a', 'r', 'e', 'm', 'a', 'm', 'm', 'e', 'l', 's', '.']
 ['T', 'h', 'e', 'y', 'l', 'i', 'v', 'e', 'o', 'n'  …  'h', 'e', 'i', 'n', 't', 'e', 'r', 'n', 'e', 't']

julia> # Join all words using spaces, keep other structure
        join_levels(animal_info, Dict(3=>" ")) |> full_collect
2-element Array{Array{String,1},1}:
 String["Turtles are reptiles .", "They have shells .", "They live in the water"]
 String["Cats are mammals .", "They live on the internet"]

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
       merge_levels(animal_info, lvls(indexer, :sentences)) |> full_collect
2-element Array{Array{String,1},1}:
 String["Turtles", "are", "reptiles", ".", "They", "have", "shells", ".", "They", "live", "in", "the", "water"]
 String["Cats", "are", "mammals", ".", "They", "live", "on", "the", "internet"]

julia> # Merge everything **except** words
       merge_levels(animal_info, (!lvls)(indexer, :words)) |> full_collect
22-element Array{String,1}:
 "Turtles"
 "are"
 "reptiles"
 "."
 "They"
 "have"
 "shells"
 ⋮
 "."
 "They"
 "live"
 "on"
 "the"
 "internet"

julia> # Merge everything **except** words and sentences
       merge_levels(animal_info, (!lvls)(indexer, :words, :sentences)) |> full_collect
5-element Array{Array{String,1},1}:
 String["Turtles", "are", "reptiles", "."]
 String["They", "have", "shells", "."]
 String["They", "live", "in", "the", "water"]
 String["Cats", "are", "mammals", "."]
 String["They", "live", "on", "the", "internet"]

julia> # i.e. merge documents
       merge_levels(animal_info, lvls(indexer, :documents)) |> full_collect
5-element Array{Array{String,1},1}:
 String["Turtles", "are", "reptiles", "."]
 String["They", "have", "shells", "."]
 String["They", "live", "in", "the", "water"]
 String["Cats", "are", "mammals", "."]
 String["They", "live", "on", "the", "internet"]


julia> # Join all words using spaces, join all sentences with new lines, all documents with double new lines
       join_levels(animal_info, lvls(indexer,Dict(:words=>" ", :sentences=>"\n", :documents=>"\n---\n"))) |> full_collect |> print

Turtles are reptiles .
They have shells .
They live in the water
---
Cats are mammals .
They live on the internet
```

## See also

 - [AbstractTrees.jl](https://github.com/Keno/AbstractTrees.jl): An iterator of iterators of ... etc duck-types as an `AbstractTree` and will work with AbstractTrees.jl

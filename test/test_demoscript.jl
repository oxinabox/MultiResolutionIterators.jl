using MultiResolutionIterators

animal_info = [
    [["Turtles", "are", "reptiles", "."],
     ["They", "have", "shells", "."],
     ["They", "live", "in", "the", "water", "."]],
    [["Cats", "are", "mammals", "."],
     ["They", "live", "on", "the", "internet", "."]]
    ]

# Get rid of document boundaries
merge_levels(animal_info, 1) |> full_consolidate

# Get rid of sentence boundaries, so documents made up of words
merge_levels(animal_info, 2) |> full_consolidate

# Get rid of document and sentence boundries
merge_levels(animal_info, 1:2) |> full_consolidate

# Get rid of all boundaries, just a stream of characters
merge_levels(animal_info, ALL_LEVELS) |> full_consolidate

# Get rid of word boundaries so each document is a a stream of characters
merge_levels(animal_info, [1,3]) |> full_consolidate

# Join all words using spaces, keep other structure
join_levels(animal_info, Dict(3=>" ")) |> full_consolidate


### Using Named levels

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
merge_levels(animal_info, lvls(indexer, :sentences)) |> full_consolidate

# I.e keep documents, and words
merge_levels(animal_info, (!lvls)(indexer, :words, :documents)) |> full_consolidate


# Merge everything **except** words
merge_levels(animal_info, (!lvls)(indexer, :words)) |> full_consolidate

# Merge everything **except** words and sentences
merge_levels(animal_info, (!lvls)(indexer, :words, :sentences)) |> full_consolidate

# i.e. merge documents
merge_levels(animal_info, lvls(indexer, :documents)) |> full_consolidate



# # Join all words using spaces, join all sentences with new lines, all documents with double new lines
join_levels(animal_info,
 lvls(indexer,Dict(:words=>" ", :sentences=>"\n", :documents=>"\n---\n"))) |>
 full_consolidate |> print

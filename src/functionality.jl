
"""
    merge_levels(iter, lvls)

Flatten, or merge levels.

`merge_levels(iter, 1)` coresponds to `Base.Iterators.flatten(iter)`


"""
function merge_levels(iter, lvls)
    apply_at_level(Base.Iterators.flatten, iter, lvls)
end

"""
    collect_levels(iter, levels)

Applies `collect` on the given levels.
To turn those levels from iterators into Vectors.

See also `full_collect`, which is an alias for doing this on all levels.
"""
function collect_levels(iter, lvls)
    apply_at_level(collect, iter, lvls)
end



"""
    full_collect(iter)

Collect all iterators in the structor,
converting an Iterator of Iterators of ...
into a Vector of Vectors of ...
"""
full_collect(iter) =collect_levels(iter, ALL_LEVELS)


"""
    join_levels(iter, lvl_delims::Associative)

This is the generalisation of `join`.
Use this as `join_levels(doc_sents_words, Dict(1=>"\n", 2=" "))`,
to join each word with a space, and each sentence  line with a line.

Note that the elements in the level being joined are converted to strings via `string`.
This is find if they are already strings, or characters, or numbers etc.
But if they are not, e.g. they were nonmerged layers then this often going to be unusual output.
But what exactly did you expect it to do? (Answer? Throw an error)
"""
function join_levels(iter, lvl_delims::Associative)
    apply_at_level(iter, Dict(lvl => (xs->join(xs,delim))  for (lvl,delim) in lvl_delims))
end

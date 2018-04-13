
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

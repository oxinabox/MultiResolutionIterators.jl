
abstract type Scalarness end
struct Scalar <: Scalarness end
struct NotScalar <: Scalarness end

isscalar(::Type{Any}) = NotScalar() # if we don't know the type we can't really know if scalar or not
isscalar(::Type{<:AbstractString}) = NotScalar() # We consider strings to be nonscalar
isscalar(::Type{<:Number}) = Scalar() # We consider Numbers to be scalar
isscalar(::Type{Char}) = Scalar() # We consider Sharacter to be scalar
isscalar(::Type{T}) where T = method_exists(start, (T,)) ? NotScalar() : Scalar()




"""
    apply_to_interior_levels(f, iter, lvls)

f is called on all levels up to `max_depth`
that have children and who's children (probably) have children.


`f` must be a function taking the current level number it's first argument,
and the level content as it's second.
That level is replaced with the return value of `f`
"""
function apply_to_interior_levels(ff, iter, lvls, max_depth)
    function inner(level_iter::T, cur_level) where T
        # This is a static Holy Trait dispatch
        this_scalar = isscalar(T)
        children_scalar = isscalar(eltype(T))
        inner(this_scalar, children_scalar, level_iter, cur_level)
    end

    # scalar, any children (Fall back if didn't manage to stop earlier)
    function inner(::Scalar,::Any, childs, cur_level)
        childs # This is just a scalare element
    end

    # not scalar, children scalar
    function inner(::NotScalar,::Scalar, childs, cur_level)
        # Only ops we care about are ones that act on nonscalar children
        childs
    end

    # not scalar, children not scalar (probably)
    function inner(::NotScalar, ::NotScalar, childs, cur_level)
        #TODO Workout why this needs to be <=, and not just <
        if cur_level <= max_depth
            # Only expand down if not yet at deepset level we act on
            # (This saves on allocations and time
            childs = apply(childs) do child
                inner(child, cur_level+1)
            end
        end

        ff(cur_level, childs)
    end

    inner(iter, 1)
end

"""
    apply_at_level(ff, iter, lvls)

Apply the given function `ff` at all levels specified in `lvls`
"""
function apply_at_level(ff, iter, lvls)
    max_depth = maximum(lvls)
    apply_to_interior_levels(iter, lvls, max_depth) do cur_level, childs
        if cur_level ∈ lvls
            # If on the level where we act, then act
            ff(childs)
        else
            childs
        end
    end
end


"""
    apply_at_level(iter, lvl_ops::Associative{<:Integer})

Applies a op
`ops` is a list of functions the same length as `lvls`.
`apply_pel_level` applies the given op, at the correponding level.

If only a single level and a single op is provider,
then this is identical to `apply_at_level`.
"""
function apply_at_level(iter, lvl_ops::Associative{<:Integer})
    max_depth = maximum(keys(lvl_ops))
    apply_to_interior_levels(iter, lvl_ops, max_depth) do cur_level, childs
        # if level is a key then  do the thing, else no change
        if haskey(lvl_ops, cur_level)
            lvl_ops[cur_level](childs)
        else
            childs
        end
    end
end

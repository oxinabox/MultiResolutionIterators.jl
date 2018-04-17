
abstract type Scalarness end
struct Scalar <: Scalarness end
struct NotScalar <: Scalarness end

isscalar(::Type{Any}) = NotScalar() # if we don't know the type we can't really know if scalar or not
isscalar(::Type{<:AbstractString}) = NotScalar() # We consider strings to be nonscalar
isscalar(::Type{<:Number}) = Scalar() # We consider Numbers to be scalar
isscalar(::Type{Char}) = Scalar() # We consider Sharacter to be scalar
isscalar(::Type{T}) where T = method_exists(start, (T,)) ? NotScalar() : Scalar()


"""
    apply_at_level(f, iter, lvls)

Apply a given function `f` at the `lvl`'s specified
"""
function apply_at_level(f, iter, lvls)
    function inner(level_iter::T, cur_level) where T
        # This is a static Holy Trait dispatch
        this_scalar = isscalar(T)
        children_scalar = isscalar(eltype(T))
        inner(this_scalar, children_scalar, level_iter, cur_level)
    end

    # scalar, any children (Fall back if didn't manage to stop earlier)
    function inner(::Scalar,::Any, childs, cur_level)
        childs # THis is just a scalare element
    end

    # not scalar, children scalar
    function inner(::NotScalar,::Scalar, childs, cur_level)
        # Only ops we care about are ones that act on nonscalar children
        childs
    end

    # not scalar, children not scalar (probably)
    function inner(::NotScalar, ::NotScalar, childs, cur_level)
        #TODO Workout why this needs to be <=, and not just <
        if cur_level <= maximum(lvls)
            # Only expand down if not yet at deepset level we act on
            # (This saves on allocations and time
            childs = (inner(child, cur_level+1) for child in childs)
        end

        if cur_level ∈ lvls
            # If on the level where we act, then act
            childs = f(childs)
        end
        childs
    end

    inner(iter, 1)
end



"""
    apply_per_level(iter, lvls, ops)

`ops` is a list of functions the same length as `lvls`.
`apply_pel_level` applies the given op, at the correponding level.

If only a single level and a single op is provider,
then this is identical to `apply_at_level`.
"""
function apply_per_level(iter, lvls, ops)
    lvls = collect(lvls)
    ops = collect(ops)
    @assert length(lvls) == length(ops)
    order = sortperm(lvls, rev=true)
    lvls = lvls[order]
    ops=ops[order]

    ret = iter
    for (lvl, op) in zip(lvls, ops)
        ret = MultiResolutionIterators.apply_at_level(op, ret, lvl)
    end
    ret
end

"""
     apply_per_level(iter, lvl_ops::Associative)

for lvl_ops being some
"""
apply_per_level(iter, lvl_ops::Associative) = apply_per_levels(iter, zip(lvl_ops...)...)

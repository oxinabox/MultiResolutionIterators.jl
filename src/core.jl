
abstract type Scalarness end
struct Scalar <: Scalarness end
struct NotScalar <: Scalarness end

isscalar(::Type{Any}) = NotScalar() # if we don't know the type we can't really know if scalar or not
isscalar(::Type{<:AbstractString}) = NotScalar() # We consider strings to be nonscalar
isscalar(::Type{<:Number}) = Scalar() # We consider Numbers to be scalar
isscalar(::Type{Char}) = Scalar() # We consider Sharacter to be scalar
isscalar(::Type{T}) where T = method_exists(start, (T,)) ? NotScalar() : Scalar()



function apply_at_level(f, iter, lvls)
    function inner(level_iter::T, cur_level) where T
        # This is a static Holy Trait dispatch
        this_scalar = isscalar(T)
        children_scalar = isscalar(eltype(T))
        #@show(cur_level, this_scalar, children_scalar, level_iter)
        #println()
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

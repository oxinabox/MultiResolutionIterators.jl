module MultiResolutionIterators
export ALL_LEVELS, full_collect, restring

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
    function inner(::Scalar,::Any, level_iter, cur_level)
        level_iter # THis is just a scalare element
    end

    # not scalar, children scalar
    function inner(::NotScalar,::Scalar, level_iter, cur_level)
        # Only ops we care about are ones that act on nonscalar children
        level_iter
    end

    # not scalar, children not scalar (probably)
    function inner(::NotScalar, ::NotScalar, level_iter, cur_level)
        childs = (inner(it, cur_level+1) for it in level_iter)
        if cur_level ∈ lvls
            f(childs)
        else
            childs
        end
    end

    inner(iter, 1)
end


function Base.Iterators.flatten(iter, lvls)
    apply_at_level(Base.Iterators.flatten, iter, lvls)
end

function Base.collect(iter, lvls)
    apply_at_level(collect, iter, lvls)
end

const ALL_LEVELS=0:typemax(Int)
full_collect(x) =collect(x, ALL_LEVELS)


end # module

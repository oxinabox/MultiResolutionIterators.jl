

"""
    apply(f, xs)

This is the generalisation of map used internally by MultiResolutionIterators.


The convention is that `map(f, ::T)::Vector`,
you can have `apply(f,xs)` return what ever type you want.
With the requirement that `collect(apply(f, xs))==map(f, xs)`.
(else things break)
It defaults to IterTools.imap

You can override it, to for example preserve your type,
over MultiResolutionIterators operations

For example:
```julia
struct MyType # Bad type but what ever
    content
    field
end
MultiResolutionIterators.apply(f, xs::MyType) == MyType(apply(f, xs.content), xs.field)
```
It is useful if there are other fields in your type that you want to preserve,
"""
apply(f, xs) = imap(f, xs)



"""
    consolidate(xs)

This is the generalisation of collect.
The convention is that `collect(::T)::Vector{eltype{T}}`.
`consolidate` has a weaker convention,
it is that it should return some type that has working `getindex`.
To be precise it is that  for
`consolidate(::T)::V` we have `eltype(V)==eltype(T)`,
and `∀i`, `getindex(collect(xs), ii) == getindex(consolidate(xs), ii)`

For most types it defaults to `collect`
For `String` it defaults to `identity`.

You too can override it, to for example preserve your type,
over MultiResolutionIterators operations

For example:
```julia
struct MyType # Bad type but what ever
    content
    field
end
MultiResolutionIterators.consolidate(xs::MyType) == MyType(consolidate(xs.content), xs.field)
```
It is useful if there are other fields in your type that you want to preserve,
"""
consolidate(str::AbstractString) = str

function consolidate(xs::T) where T
    ret =  collect(xs)
    if eltype(T)==Char || eltype(typeof(ret))==Char # In theory `collect` is type stable
         return String(ret) # A string is no worse (and normally better) than an array of Chars
    end
    return ret
end

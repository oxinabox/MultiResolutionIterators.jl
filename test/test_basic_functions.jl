
srand(1)
len=15
xss_base = [randstring(len), rand(1:100, len), [randstring(rand(1:10)) for ii=1:len]]
const xss =  [xss_base; Base.Iterators.flatten.(xss_base)]

@testset "consolidate" begin
    for xs in xss
        for ii in 1:len
            @test consolidate(xs)[ii] == collect(xs)[ii]
        end
    end
end

@testset "apply" begin
    f = x->x.*x
    for xs in xss
        @test map(f, collect(xs)) == collect(MultiResolutionIterators.apply(f, xs))
    end
end

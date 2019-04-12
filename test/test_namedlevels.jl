using MultiResolutionIterators
using Test


struct OneToOneIndexer end
MultiResolutionIterators.levelname_map(::OneToOneIndexer) = [
    :doc=>1,
    :para=>2,
    :sent=>3,
    :word=>4,
    :char=>5
]

struct ManyToOneIndexer end
MultiResolutionIterators.levelname_map(::ManyToOneIndexer) = [
    :doc=>1,
    :para=>2, :section=>2, :block=>2,
    :sent=>3,
    :word=>4, :token=>4,
    :char=>5
]


@testset "Unit common $indexer" for indexer in [OneToOneIndexer(), ManyToOneIndexer()]
    @testset "include lvls" begin
        @test lvls(indexer)|>Set == Set()
        @test lvls(indexer, 2)|>Set ==
              lvls(indexer, :para)|>Set ==
              [2] |>Set

        @test lvls(indexer, 4)|>Set ==
            lvls(indexer, :word)|>Set ==
            [4] |>Set

        @test lvls(indexer, 2, 4)|>Set ==
            lvls(indexer, :para, :word)|>Set ==
            [2, 4] |>Set

    end

    @testset "exclude levels (!lvls)" begin
        @test (!lvls)(indexer)|>Set == 1:5 |>Set

        @test (!lvls)(indexer, 2)|>Set ==
              (!lvls)(indexer, :para)|>Set ==
              [1,3,4,5] |>Set

        @test (!lvls)(indexer, 4)|>Set ==
              (!lvls)(indexer, :word)|>Set ==
              [1,2,3,5] |>Set

        @test (!lvls)(indexer, 2, 4)|>Set ==
          (!lvls)(indexer, :para, :word)|>Set ==
          [1,3,5] |>Set
    end
end

@testset "ManyToOneIndexer overlap" begin
    indexer = ManyToOneIndexer()
    @testset "lvls" begin
        @test_throws ArgumentError lvls(indexer, :fish)

        @test lvls(indexer)|>Set == Set()
        @test lvls(indexer, :para)|>Set ==
              lvls(indexer, :para, :section)|>Set ==
              [2] |>Set

        @test lvls(indexer, :token)|>Set ==
            lvls(indexer, :word, :word)|>Set ==
            [4] |>Set

        @test lvls(indexer, :para, :word)|>Set ==
            lvls(indexer, :para, :block, :word)|>Set ==
            [2, 4] |>Set

    end

    @testset "(!lvls)" begin
        @test (!lvls)(indexer)|>Set == 1:5 |>Set

        @test (!lvls)(indexer, :para)|>Set ==
              (!lvls)(indexer, :para, :section)|>Set ==
              [1,3,4,5] |>Set

        @test (!lvls)(indexer, :token)|>Set ==
              (!lvls)(indexer, :word, :token)|>Set ==
              [1,2,3,5] |>Set

        @test (!lvls)(indexer, :para, :word,)|>Set ==
          (!lvls)(indexer, :para, :block, :word)|>Set ==
          [1,3,5] |>Set
      end
end


@testset "Dict checking" for indexer in [OneToOneIndexer(), ManyToOneIndexer()]
    @test lvls(indexer, Dict(2=>"a")) ==
          lvls(indexer, Dict(:para=>"a")) ==
          Dict(2=>"a")

    @test lvls(indexer, Dict(4=>"b")) ==
        lvls(indexer, Dict(:word=>"b")) ==
        Dict(4=>"b")

    @test lvls(indexer, Dict(4=>"b", 2=>"a")) ==
        lvls(indexer, Dict(:word=>"b", :para=>"a")) ==
        Dict(4=>"b", 2=>"a")

    @test lvls(indexer, Dict(1=>"d", 4=>"b", 2=>"a")) ==
        lvls(indexer, Dict(:doc=>"d", :word=>"b", :para=>"a")) ==
        Dict(1=>"d", 4=>"b", 2=>"a")
end

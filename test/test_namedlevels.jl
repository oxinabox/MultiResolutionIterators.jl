using MultiResolutionIterators
using Base.Test

using MultiResolutionIterators: include_levels, exclude_levels


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
    @testset "include_levels" begin
        @test include_levels(indexer)|>Set == Set()
        @test include_levels(indexer, 2)|>Set ==
              include_levels(indexer, :para)|>Set ==
              [2] |>Set

        @test include_levels(indexer, 4)|>Set ==
            include_levels(indexer, :word)|>Set ==
            [4] |>Set

        @test include_levels(indexer, 2, 4)|>Set ==
            include_levels(indexer, :para, :word)|>Set ==
            [2, 4] |>Set

    end

    @testset "exclude_levels" begin
        @test exclude_levels(indexer)|>Set == 1:5 |>Set

        @test exclude_levels(indexer, 2)|>Set ==
              exclude_levels(indexer, :para)|>Set ==
              [1,3,4,5] |>Set

        @test exclude_levels(indexer, 4)|>Set ==
              exclude_levels(indexer, :word)|>Set ==
              [1,2,3,5] |>Set

        @test exclude_levels(indexer, 2, 4)|>Set ==
          exclude_levels(indexer, :para, :word)|>Set ==
          [1,3,5] |>Set
    end
end

@testset "ManyToOneIndexer overlap" begin
    indexer = ManyToOneIndexer()
    @testset "include_levels" begin
        @test include_levels(indexer)|>Set == Set()
        @test include_levels(indexer, :para)|>Set ==
              include_levels(indexer, :para, :section)|>Set ==
              [2] |>Set

        @test include_levels(indexer, :token)|>Set ==
            include_levels(indexer, :word, :word)|>Set ==
            [4] |>Set

        @test include_levels(indexer, :para, :word)|>Set ==
            include_levels(indexer, :para, :block, :word)|>Set ==
            [2, 4] |>Set

    end

    @testset "exclude_levels" begin
        @test exclude_levels(indexer)|>Set == 1:5 |>Set

        @test exclude_levels(indexer, :para)|>Set ==
              exclude_levels(indexer, :para, :section)|>Set ==
              [1,3,4,5] |>Set

        @test exclude_levels(indexer, :token)|>Set ==
              exclude_levels(indexer, :word, :token)|>Set ==
              [1,2,3,5] |>Set

        @test exclude_levels(indexer, :para, :word,)|>Set ==
          exclude_levels(indexer, :para, :block, :word)|>Set ==
          [1,3,5] |>Set
      end
end

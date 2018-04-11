using MultiResolutionIterators
using Base.Test
using Base.Iterators

eg =   [["aaaa", "bbbb", "ccc"], ["AAA", "BB", "CCC", "DDDDD"], ["111","222"]]

@testset "basic 1" begin
    eg =   [["aaaa", "bbbb", "ccc"], ["AAA", "BB", "CCC", "DDDDD"], ["111","222"]]

    @test full_collect(eg) == eg

    @test full_collect(flatten(eg, 1)) ==
        full_collect(["aaaa", "bbbb", "ccc","AAA", "BB", "CCC", "DDDDD", "111","222"]) ==
        ["aaaa", "bbbb", "ccc","AAA", "BB", "CCC", "DDDDD", "111","222"]

    @test full_collect(flatten(eg, 2)) == collect.(["aaaabbbbccc","AAABBCCCDDDDD","111222"])

    @test full_collect(flatten(eg, 1:2)) ==
        collect(flatten(eg, 1:2)) ==
        full_collect(flatten(eg, ALL_LEVELS))
        collect("aaaabbbbcccAAABBCCCDDDDD111222")
end


@testset "turtles" begin
    # From
    #  https://simple.wikipedia.org/wiki/Turtle ,
    #  https://simple.wikipedia.org/wiki/Sea_turtle ,
    #  https://simple.wikipedia.org/wiki/Green_turtle
    raw = """Turtles are the reptile order Testudines.
    They have a special bony or cartilaginous shell developed from their ribs that acts as a shield.

    The order Testudines includes both living and extinct species.
    The earliest fossil turtles date from about 220 million years ago.
    So turtles are one of the oldest surviving reptile groups and a more ancient group than lizards, snakes and crocodiles.

    Turtle have been very successful, and have almost world-wide distribution.
    But, of the many species alive today, some are highly endangered.
    -----------------------------------------
    Sea turtles (Chelonioidea) are turtles found in all the world's oceans except the Arctic Ocean, and some species travel between oceans.
    The term is US English.
    In British English they are simply called "turtles"; fresh-water chelonians are called "terrapins" and land chelonians are called tortoises.

    There are seven types of sea turtles: Kemp's Ridley, Flatback, Green, Olive Ridley, Loggerhead, Hawksbill and the leatherback.
    All but the leatherback are in the family Chelonioidea.
    The leatherback belongs to the family Dermochelyidae and is its only member.
    The leatherback sea turtle is the largest, measuring six or seven feet (2 m) in length at maturity, and three to five feet (1 to 1.5 m) in width, weighing up to 2000 pounds (about 900 kg).
    Most other species are smaller, being two to four feet in length (0.5 to 1 m) and proportionally less wide.
    The Flatback turtle is found solely on the northern coast of Australia.
    -----------------------------------------
    Chelonia mydas, commonly known as the green turtle, is a large sea turtle belonging to the family Cheloniidae.
    It is the only species in its genus.
    It is one of the seven marine turtles, which are all endangered.

    Although it might have some green on its carapace (shell), the green turtle is not green.
    It gets its name from the fact that its body fat is green.
    It can grow up to 1 m (3 ft) long and weigh up to 160 kg (353 lb).
    They are an endangered species, especially in Florida and the Pacific coast of Mexico.
    They can also be found in warm waters around the world and are found along the coast of 140 countries.

    The female turtle lays eggs in nests she builds in the sand on the beaches.
    She uses the same beach that she was born on.
    During the nesting season in summer she can make up to five nests.
    She can lay as many as 135 eggs in a nest.
    The eggs take about two months to hatch.
    The baby turtles are about 50 mm (2 in) in length."""


    multi_tokenized = [
        [[["Turtles", "are", "the", "reptile", "order", "Testudines", "."], ["They", "have", "a", "special", "bony", "or", "cartilaginous", "shell", "developed", "from", "their", "ribs", "that", "acts", "as", "a", "shield", "."]], [["The", "order", "Testudines","includes", "both", "living", "and", "extinct", "species", "."], ["The", "earliest", "fossil", "turtles", "date","from", "about", "220", "million", "years", "ago", "."], ["So", "turtles", "are", "one", "of", "the", "oldest", "surviving", "reptile", "groups", "and", "a", "more", "ancient", "group", "than", "lizards", ",", "snakes", "and", "crocodiles", "."]], [["Turtle", "have", "been", "very", "successful", ",", "and", "have", "almost", "world-wide", "distribution", "."], ["But", ",", "of", "the", "many", "species", "alive", "today", ",", "some", "are","highly", "endangered", "."]]],
        [[["Sea", "turtles", "(", "Chelonioidea", ")", "are", "turtles", "found", "in", "all", "the", "world", "'s", "oceans", "except", "the", "Arctic", "Ocean", ",", "and", "some", "species", "travel", "between", "oceans", "."], ["The", "term", "is", "US", "English", "."],["In", "British", "English", "they", "are", "simply", "called", "``", "turtles", "''", ";", "fresh-water", "chelonians", "are", "called", "``", "terrapins", "''", "and", "land", "chelonians", "are", "called", "tortoises", "."]], [["There", "are", "seven", "types", "of", "sea", "turtles", ":", "Kemp", "'s", "Ridley", ",", "Flatback", ",", "Green", ",", "Olive", "Ridley", ",", "Loggerhead", ",", "Hawksbill", "and", "the", "leatherback", "."], ["All", "but", "the", "leatherback", "are", "in", "the", "family", "Chelonioidea", "."], ["The", "leatherback", "belongs", "to", "the", "family", "Dermochelyidae", "and", "is", "its", "only", "member", "."], ["The", "leatherback", "sea", "turtle", "is", "the", "largest", ",", "measuring", "six", "or", "seven", "feet", "(", "2", "m", ")", "in", "length", "at", "maturity", ",", "and", "three", "to", "five", "feet", "(", "1", "to", "1.5", "m", ")", "in", "width", ",", "weighing", "up", "to", "2000", "pounds", "(", "about", "900", "kg", ")", "."], ["Most", "other", "species", "are", "smaller", ",", "being", "two", "to", "four", "feet", "in", "length", "(", "0.5", "to", "1", "m", ")", "and", "proportionally", "less", "wide", "."], ["The", "Flatback", "turtle", "is", "found", "solely", "on", "the", "northern", "coast", "of", "Australia", "."]]],
        [[["Chelonia", "mydas", ",", "commonly", "known", "as", "the", "green", "turtle", ",", "is", "a", "large", "sea", "turtle", "belonging", "to", "the", "family", "Cheloniidae", "."], ["It", "is", "the", "only", "species", "in", "its", "genus", "."], ["It", "is", "one", "of", "the", "seven", "marine", "turtles", ",", "which", "are", "all", "endangered", "."]], [["Although", "it", "might", "have", "some", "green", "on", "its", "carapace", "(", "shell", ")", ",", "the", "green", "turtle", "is", "not", "green", "."], ["It", "gets", "its", "name", "from", "the", "fact", "that", "its", "body", "fat", "is", "green","."], ["It", "can", "grow", "up", "to", "1", "m", "(", "3", "ft", ")", "long", "and", "weigh", "up", "to", "160","kg", "(", "353", "lb", ")", "."], ["They", "are", "an", "endangered", "species", ",", "especially", "in", "Florida", "and", "the", "Pacific", "coast", "of", "Mexico", "."], ["They", "can", "also", "be", "found", "in", "warm", "waters", "around", "the", "world", "and", "are", "found", "along", "the", "coast", "of", "140", "countries", "."]], [["The", "female", "turtle", "lays", "eggs", "in", "nests", "she", "builds", "in", "the", "sand", "on", "the", "beaches", "."], ["She", "uses", "the", "same", "beach", "that", "she", "was", "born", "on", "."], ["During", "the", "nesting", "season", "in", "summer", "she", "can", "make", "up", "to", "five", "nests", "."], ["She", "can", "lay", "as", "many", "as", "135", "eggs", "in", "a", "nest", "."], ["The", "eggs", "take","about", "two", "months", "to", "hatch", "."], ["The", "baby", "turtles", "are", "about", "50", "mm", "(", "2", "in", ")", "in", "length", "."]]]
        ]

    documents = full_collect(flatten(multi_tokenized, 0))
    #corpus, doc, para, sent, word, char
    @test length(documents)==3
    @test typeof(documents[1][1][1][1])==String # words
    @test typeof(documents[1][1][1][1][1])==Char

    paras = full_collect(flatten(multi_tokenized, 1))
    #corpus, para, sent, word, char
    @test length(paras) == sum(length.(documents))
    @test typeof(paras[1][1][1])==String # words
    @test typeof(paras[1][1][1][1])==Char

    words = full_collect(flatten(multi_tokenized, 1:3))
    #corpus, word, char
    @test typeof(words[1])==String
    @test typeof(words[end])==String

    docs_of_words = full_collect(flatten(multi_tokenized, 2:3))
    #corpus, doc, word, char
    @test length(docs_of_words)==3
    @test typeof(docs_of_words[1][1])==String

    @test full_collect(flatten(docs_of_words, 1)) ==
          full_collect(flatten(paras, 1:2)) ==
          words

    chars = full_collect(flatten(multi_tokenized, ALL_LEVELS))
    @test typeof(chars[1]) == Char

    @test full_collect(flatten(docs_of_words, ALL_LEVELS)) ==
          full_collect(flatten(paras, ALL_LEVELS)) ==
          full_collect(flatten(words, ALL_LEVELS)) ==
          chars
end

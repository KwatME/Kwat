using OrderedCollections: OrderedDict

using Test: @test

using BioLab

# ---- #

const DA = joinpath(BioLab._DA, "Dict")

# ---- #

@test readdir(DA) == ["example.toml", "example_1.json", "example_2.json"]

# ---- #

const DI1 = Dict("Existing" => 1)

# ---- #

for (ke, va, re) in (
    ("Existing", 1, DI1),
    ("Existing", 2, Dict("Existing" => 2)),
    ("New", 3, Dict("Existing" => 1, "New" => 3)),
)

    co = copy(DI1)

    BioLab.Dict.set!(co, ke, va)

    @test co == re

end

# ---- #

for (ke, va, re) in (
    ("Existing", 1, Dict("Existing" => 1, "Existing.2" => 1)),
    ("Existing", 2, Dict("Existing" => 1, "Existing.2" => 2)),
    ("New", 3, Dict("Existing" => 1, "New" => 3)),
)

    co = copy(DI1)

    BioLab.Dict.set_with_suffix!(co, ke, va)

    @test co == re

end

# ---- #

const DI2 = Dict("1A" => 1, "B" => Dict("C" => 1, "1D" => 1))

const DI3 = Dict("2A" => 2, "B" => Dict("C" => 2, "2D" => 2))

@test BioLab.Dict.merge(DI2, DI3) ==
      Dict("1A" => 1, "2A" => 2, "B" => Dict("C" => 2, "1D" => 1, "2D" => 2))


@test BioLab.Dict.merge(DI3, DI2) ==
      Dict("1A" => 1, "2A" => 2, "B" => Dict("C" => 1, "1D" => 1, "2D" => 2))

for (di1, di2, re) in (
    (Dict(1 => 'a'), Dict(2 => 'b'), Dict{Int, Char}),
    (Dict(1.0 => 'a'), Dict(2 => "Bb"), Dict{Float64, Any}),
    (Dict(1.0 => "Aa"), Dict(2 => chop("Bbx")), Dict{Float64, AbstractString}),
)

    @test BioLab.Dict.merge(di1, di2) isa re

end

# ---- #

const JS1 = joinpath(DA, "example_1.json")

for dicttype in (Dict, OrderedDict, OrderedDict{String, String})

    @test BioLab.Dict.read(JS1, dicttype) isa dicttype

end

@test BioLab.Dict.read(JS1) == OrderedDict("fruit" => "Apple", "color" => "Red", "size" => "Large")

# ---- #

@test BioLab.Dict.read(joinpath(DA, "example_2.json")) == OrderedDict{String, Any}(
    "quiz" => Dict{String, Any}(
        "sport" => Dict{String, Any}(
            "q1" => Dict{String, Any}(
                "options" => Any[
                    "New York Bulls",
                    "Los Angeles Kings",
                    "Golden State Warriros",
                    "Huston Rocket",
                ],
                "question" => "Which one is correct team name in NBA?",
                "answer" => "Huston Rocket",
            ),
        ),
        "maths" => Dict{String, Any}(
            "q1" => Dict{String, Any}(
                "options" => Any["10", "11", "12", "13"],
                "question" => "5 + 7 = ?",
                "answer" => "12",
            ),
            "q2" => Dict{String, Any}(
                "options" => Any["1", "2", "3", "4"],
                "question" => "12 - 8 = ?",
                "answer" => "4",
            ),
        ),
    ),
)

# ---- #

@test BioLab.Dict.read(joinpath(DA, "example.toml")) == Dict{String, Any}(
    "servers" => Dict{String, Any}(
        "alpha" => Dict{String, Any}("dc" => "eqdc10", "ip" => "10.0.0.1"),
        "beta" => Dict{String, Any}("dc" => "eqdc10", "ip" => "10.0.0.2"),
    ),
    "clients" => Dict{String, Any}(
        "hosts" => ["alpha", "omega"],
        "data" => Union{Vector{Int64}, Vector{String}}[["gamma", "delta"], [1, 2]],
    ),
    "owner" => Dict{String, Any}("name" => "Tom Preston-Werner"),
    "title" => "TOML Example",
    "database" => Dict{String, Any}(
        "server" => "192.168.1.1",
        "connection_max" => 5000,
        "ports" => [8000, 8001, 8002],
        "enabled" => true,
    ),
)

# ---- #

const DI4 = Dict(
    "Luffy" => "Pirate King",
    "Crews" => [
        "Luffy",
        "Zoro",
        "Nami",
        "Usopp",
        "Sanji",
        "Chopper",
        "Robin",
        "Franky",
        "Brook",
        "Jinbe",
    ],
    "episode" => 1030,
)

const JS2 = joinpath(BioLab.TE, "write_read.json")

BioLab.Dict.write(JS2, DI4)

@test DI4 == BioLab.Dict.read(JS2)

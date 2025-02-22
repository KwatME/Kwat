using Test: @test

using Nucleus

# ----------------------------------------------------------------------------------------------- #

for na in (
    "Animation",
    "BubblePlot",
    "Color",
    "ColorScheme",
    "Confidence",
    "Dictionary",
    "Extreme",
    "HTM",
    "HeatPlot",
    "Information",
    "Map",
    "Normalization",
    "Numbe",
    "Pai",
    "PairMetric",
    "Path",
    "Plotly",
    "RangeNormalization",
    "RankNormalization",
    "Significance",
    "Strin",
    "Table",
    "Tex",
    "Time",
)

    @info "🎬 Testing $na"

    run(`julia --project $na.jl`)

end

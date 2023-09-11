module Plot

using JSON: json

using ..BioLab

function plot(ht, data, layout = Dict{String, Any}(), config = Dict{String, Any}(); ke_ar...)

    id = "Plotly"

    BioLab.HTML.make(
        ht,
        ("https://cdn.plot.ly/plotly-latest.min.js",),
        id,
        "Plotly.newPlot(\"$id\", $(json(data)), $(json(layout)), $(json(merge(Dict("displaylogo" => false), config))))";
        ke_ar...,
    )

end

function _set_x(y_)

    (y -> collect(eachindex(y))).(y_)

end

function _set_text(y_)

    [Vector{String}() for _ in eachindex(y_)]

end

function _set_name(y_)

    ["Name $id" for id in eachindex(y_)]

end

function _set_marker(y_)

    [Dict("color" => co) for co in BioLab.Color.color(collect(eachindex(y_)))]

end

const COLORBAR = Dict(
    "len" => 0.5,
    "thickness" => 16,
    "outlinecolor" => BioLab.Color.HEFA,
    "title" => Dict("font" => Dict("family" => "Droid Sans Mono", "size" => 12.8)),
    "tickfont" => Dict("family" => "Droid Sans Mono", "size" => 10),
)

const SPIKE = Dict(
    "showspikes" => true,
    "spikesnap" => "cursor",
    "spikemode" => "across",
    "spikedash" => "solid",
    "spikethickness" => 1,
    "spikecolor" => "#561649",
)

function plot_scatter(
    ht,
    y_;
    x_ = _set_x(y_),
    text_ = _set_text(y_),
    name_ = _set_name(y_),
    mode_ = (y -> ifelse(length(y) < 1000, "markers+lines", "lines")).(y_),
    marker_ = _set_marker(y_),
    layout = Dict{String, Any}(),
    ke_ar...,
)

    plot(
        ht,
        [
            Dict(
                "name" => name_[id],
                "y" => y_[id],
                "x" => x_[id],
                "text" => text_[id],
                "mode" => mode_[id],
                "marker" => marker_[id],
            ) for id in eachindex(y_)
        ],
        BioLab.Dict.merge(
            Dict("yaxis" => Dict("showgrid" => false), "xaxis" => Dict("showgrid" => false)),
            layout,
        );
        ke_ar...,
    )

end

function plot_bar(
    ht,
    y_,
    x_ = _set_x(y_);
    name_ = _set_name(y_),
    marker_ = _set_marker(y_),
    layout = Dict{String, Any}(),
    ke_ar...,
)

    plot(
        ht,
        [
            Dict(
                "type" => "bar",
                "name" => name_[id],
                "y" => y_[id],
                "x" => x_[id],
                "marker" => marker_[id],
            ) for id in eachindex(y_)
        ],
        BioLab.Dict.merge(
            Dict("yaxis" => Dict("showgrid" => false), "xaxis" => Dict("showgrid" => false)),
            layout,
        );
        ke_ar...,
    )

end

# TODO: Fit and plot a line.
function plot_histogram(
    ht,
    x_,
    text_ = _set_text(x_);
    rug_marker_size = ifelse(all(x -> length(x) < 100000, x_), 16, 0),
    name_ = _set_name(x_),
    marker_ = _set_marker(x_),
    histnorm = "",
    xbins_size = 0,
    layout = Dict{String, Any}(),
    ke_ar...,
)

    n = length(x_)

    if 0 < rug_marker_size

        fr = min(n * 0.08, 0.5)

    else

        fr = 0

    end

    if isempty(histnorm)

        yaxis2_title_text = "Count"

    else

        yaxis2_title_text = titlecase(histnorm)

    end

    data = Vector{Dict{String, Any}}()

    showlegend = 1 < n

    for id in 1:n

        x = x_[id]

        le = Dict(
            "legendgroup" => id,
            "showlegend" => showlegend,
            "name" => name_[id],
            "x" => x,
            "marker" => marker_[id],
        )

        push!(
            data,
            merge(
                le,
                Dict(
                    "yaxis" => "y2",
                    "type" => "histogram",
                    "histnorm" => histnorm,
                    "xbins" => Dict("size" => xbins_size),
                ),
            ),
        )

        if 0 < rug_marker_size

            push!(
                data,
                BioLab.Dict.merge(
                    le,
                    Dict(
                        "showlegend" => false,
                        "y" => fill(id, length(x)),
                        "text" => text_[id],
                        "mode" => "markers",
                        "marker" => Dict("symbol" => "line-ns-open", "size" => rug_marker_size),
                    ),
                ),
            )

        end

    end

    plot(
        ht,
        data,
        BioLab.Dict.merge(
            Dict(
                "yaxis2" => Dict(
                    "domain" => (fr, 1),
                    "showgrid" => false,
                    "title" => Dict("text" => yaxis2_title_text),
                ),
                "yaxis" => Dict("domain" => (0, fr), "zeroline" => false, "tickvals" => ()),
            ),
            layout,
        );
        ke_ar...,
    )

end

# TODO: Cluster within a group.
function plot_heat_map(
    ht,
    z;
    y = ["$id *" for id in 1:size(z, 1)],
    x = ["* $id" for id in 1:size(z, 2)],
    text = z,
    nar = "Row",
    nac = "Column",
    colorscale = BioLab.Color.fractionate(BioLab.Color.pick_color_scheme(z)),
    grr_ = Vector{Any}(),
    grc_ = Vector{Any}(),
    layout = Dict{String, Any}(),
    ke_ar...,
)

    if isempty(grr_)

        colorbarx = 0.97

    else

        colorbarx = 1.024

    end

    dx = 0.08

    n_ti = 8

    data = [
        Dict(
            "type" => "heatmap",
            "z" => collect(eachrow(z)),
            "y" => y,
            "x" => x,
            "text" => collect(eachrow(text)),
            "colorscale" => colorscale,
            "colorbar" => merge(
                COLORBAR,
                Dict("x" => colorbarx, "tickvals" => BioLab.Collection.range(z, n_ti)),
            ),
        ),
    ]

    if !isempty(grr_)

        if grr_ isa AbstractVector{<:AbstractString}

            gr_id = BioLab.Collection.map_index(BioLab.Collection.unique_sort(grr_))

            grr_ = [gr_id[gr] for gr in grr_]

            ticktext = collect(keys(sort(gr_id; byvalue = true)))

        else

            ticktext = ()

        end

        so_ = sortperm(grr_)

        grr_ = view(grr_, so_)

        y = view(y, so_)

        z = view(z, so_, :)

        push!(
            data,
            Dict(
                "xaxis" => "x2",
                "type" => "heatmap",
                "z" => [[grr] for grr in grr_],
                "colorscale" => BioLab.Color.fractionate(BioLab.Color.pick_color_scheme(grr_)),
                "colorbar" => merge(
                    COLORBAR,
                    Dict(
                        "x" => (colorbarx += dx),
                        "tickvals" => BioLab.Collection.range(grr_, n_ti),
                        "ticktext" => ticktext,
                    ),
                ),
            ),
        )

    end

    if !isempty(grc_)

        if grc_ isa AbstractVector{<:AbstractString}

            gr_id = BioLab.Collection.map_index(BioLab.Collection.unique_sort(grc_))

            grc_ = [gr_id[gr] for gr in grc_]

            ticktext = collect(keys(sort(gr_id; byvalue = true)))

        else

            ticktext = ()

        end

        so_ = sortperm(grc_)

        grc_ = view(grc_, so_)

        x = view(x, so_)

        z = view(z, :, so_)

        push!(
            data,
            Dict(
                "yaxis" => "y2",
                "type" => "heatmap",
                "z" => [grc_],
                "colorscale" => BioLab.Color.fractionate(BioLab.Color.pick_color_scheme(grc_)),
                "colorbar" => merge(
                    COLORBAR,
                    Dict(
                        "x" => (colorbarx += dx),
                        "tickvals" => BioLab.Collection.range(grc_, n_ti),
                        "ticktext" => ticktext,
                    ),
                ),
            ),
        )

    end

    n_ro, n_co = size(z)

    ydomain = (0, 0.939)

    xdomain = (0, 0.955)

    dd = 0.02

    plot(
        ht,
        data,
        BioLab.Dict.merge(
            Dict(
                "yaxis" => Dict(
                    "domain" => ydomain,
                    "autorange" => "reversed",
                    "title" => Dict("text" => "$nar (n = $n_ro)"),
                ),
                "xaxis" =>
                    Dict("domain" => xdomain, "title" => Dict("text" => "$nac (n = $n_co)")),
                "yaxis2" => Dict(
                    "domain" => (ydomain[2] + dd, 1),
                    "autorange" => "reversed",
                    "tickvals" => (),
                ),
                "xaxis2" => Dict("domain" => (xdomain[2] + dd, 1), "tickvals" => ()),
            ),
            layout,
        );
        ke_ar...,
    )

end

function plot_radar(
    ht,
    theta_,
    r_;
    radialaxis_range = (0, maximum(vcat(r_...))),
    name_ = _set_name(theta_),
    line_color_ = BioLab.Color.color(collect(eachindex(theta_))),
    fillcolor_ = line_color_,
    layout = Dict{String, Any}(),
    ke_ar...,
)

    cos = "#b83a4b"

    plot(
        ht,
        [
            Dict(
                "type" => "scatterpolar",
                "name" => name_[id],
                "theta" => vcat(theta_[id], theta_[id][1]),
                "r" => vcat(r_[id], r_[id][1]),
                "line" => Dict(
                    "shape" => "spline",
                    "smoothing" => 0,
                    "width" => 1,
                    "color" => line_color_[id],
                ),
                "marker" => Dict("size" => 4, "color" => line_color_[id]),
                "fill" => "toself",
                "fillcolor" => fillcolor_[id],
            ) for id in eachindex(theta_)
        ],
        BioLab.Dict.merge(
            Dict(
                "polar" => Dict(
                    "angularaxis" => Dict(
                        "direction" => "clockwise",
                        "linewidth" => 4,
                        "linecolor" => cos,
                        "ticklen" => 16,
                        "tickwidth" => 2,
                        "tickcolor" => cos,
                        "tickfont" =>
                            Dict("size" => 32, "family" => "Optima", "color" => "#23191e"),
                        "gridwidth" => 2,
                        "gridcolor" => BioLab.Color.HEFA,
                    ),
                    "radialaxis" => Dict(
                        "range" => radialaxis_range,
                        "linewidth" => 2,
                        "linecolor" => cos,
                        "ticklen" => 8,
                        "tickwidth" => 2,
                        "tickcolor" => cos,
                        "tickfont" => Dict(
                            "size" => 16,
                            "family" => "Monospace",
                            "color" => "#1f4788",
                        ),
                        "gridwidth" => 1.6,
                        "gridcolor" => BioLab.Color.HEFA,
                    ),
                ),
                "title" => Dict(
                    "x" => 0.02,
                    "font" => Dict(
                        "size" => 48,
                        "family" => "Times New Roman",
                        "color" => "#27221f",
                    ),
                ),
            ),
            layout,
        );
        ke_ar...,
    )

end

function animate(gi, pn_)

    run(`convert -delay 32 -loop 0 $pn_ $gi`)

    BioLab.Path.open(gi)

    gi

end

end

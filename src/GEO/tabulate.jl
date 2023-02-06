function _name(pl, fe_x_in_x_an; pr = true)

    pl = parse(Int, pl[4:end])

    println("🚉 $pl")

    ke = "ID"

    if pl in (96, 97, 570)

        va = "Gene Symbol"

        fu = na -> BioLab.String.split_and_get(na, " /// ", 1)

    elseif pl == 13534

        va = "UCSC_RefGene_Name"

        fu = na -> BioLab.String.split_and_get(na, ";", 1)

    elseif pl in (5175, 11532)

        va = "gene_assignment"

        fu = na -> BioLab.String.split_and_get(na, " // ", 2)

    elseif pl in (2004, 2005, 3718, 3720)

        va = "Associated Gene"

        fu = na -> BioLab.String.split_and_get(na, " // ", 1)

    elseif pl in (10558, 14951, 6947, 6098)

        va = "Symbol"

        fu = na -> na

    elseif pl == 16686

        va = "GB_ACC"

        fu = na -> na

    else

        error(pl)

    end

    if pr

        println("🧭 Mapping paltform features using the platform table ($ke ➡️ $va)")

        println(first(fe_x_in_x_an, 2))

    end

    fe_na = Dict{String, String}()

    for (fe, na) in zip(fe_x_in_x_an[!, ke], fe_x_in_x_an[!, va])

        if na isa AbstractString && !isempty(na) && !(na in ("---",))

            BioLab.Dict.set!(fe_na, fe, fu(na), pr = pr)

        end

    end

    if pr

        BioLab.Dict.print(fe_na, 0)

    end

    fe_na

end

function tabulate(ty_bl, sa = "!Sample_title"; pr = true)

    sa_ke_va = OrderedDict(ke_va[sa] => ke_va for ke_va in values(ty_bl["SAMPLE"]))

    ch = "Characteristic"

    de = ": "

    co_st____ = Vector{Dict{String, Vector{String}}}()

    pl_co_nu____ = Dict{String, Vector{Dict{String, Vector{Union{String, Float64}}}}}()

    for (sa, ke_va) in sa_ke_va

        ch_ = [va for (ke, va) in ke_va if startswith(ke, "!Sample_characteristics")]

        if all(occursin(de, ch) for ch in ch_)

            sp_ = [split(ch, de, limit = 2) for ch in ch_]

            push!(co_st____, Dict(ch => [sp[1] for sp in sp_], sa => [sp[2] for sp in sp_]))

        else

            println("⚠️ A $sa characteristic lacks \"$de\":\n  $(join(ch_, "\n  "))")

        end

        pl = ke_va["!Sample_platform_id"]

        co_nu____ = get!(pl_co_nu____, pl, [])

        if haskey(ke_va, "fe_x_in_x_an")

            fe_x_in_x_an = ke_va["fe_x_in_x_an"]

            push!(
                co_nu____,
                Dict(
                    pl => string.(fe_x_in_x_an[!, 1]),
                    sa => parse.(Float64, fe_x_in_x_an[!, "VALUE"]),
                ),
            )

        else

            println("⚠️ $sa table is empty.")

        end

    end

    ch_x_sa_x_an = _outerjoin(co_st____, ch)

    if pr

        BioLab.DataFrame.print_unique(ch_x_sa_x_an)

    end

    fe_x_sa_x_nu_____ = []

    for (pl, co_nu____) in pl_co_nu____

        fe_x_sa_x_nu = _outerjoin(co_nu____, pl)

        pl_ke_va = ty_bl["PLATFORM"]

        if haskey(pl_ke_va[pl], "fe_x_in_x_an")

            fe_na = _name(pl, pl_ke_va[pl]["fe_x_in_x_an"]; pr = pr)

            fe_x_sa_x_nu[!, pl] = [get(fe_na, fe, "_$fe") for fe in fe_x_sa_x_nu[!, pl]]

            n_fe = size(fe_x_sa_x_nu, 1)

            println(
                "📛 Renamed $(n_fe - count(startswith('_'), fe_x_sa_x_nu[!, 1])) / $n_fe $pl $(BioLab.String.count_noun(n_fe,"feature")).",
            )

        else

            println("⚠️ $pl table is empty.")

        end

        push!(fe_x_sa_x_nu_____, fe_x_sa_x_nu)

    end

    ch_x_sa_x_an, fe_x_sa_x_nu_____...

end

function _outerjoin(co_va____, on)

    if isempty(co_va____)

        fe_x_co_x_va = DataFrame()

    else

        fe_x_co_x_va = select!(outerjoin(DataFrame.(co_va____)...; on = on), on, :)

    end

    fe_x_co_x_va

end

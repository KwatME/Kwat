module Collection

function is_in(a1_, a2_)

    map(in(Set(a2_)), a1_)

end

function is_in!(bo_, di, an_)

    for an in an_

        id = get(di, an, nothing)

        if !isnothing(id)

            bo_[id] = true

        end

    end

end

function index(an_)

    di = Dict{eltype(an_), Vector{Int}}()

    for id in eachindex(an_)

        an = an_[id]

        if !haskey(di, an)

            di[an] = Int[]

        end

        push!(di[an], id)

    end

    di

end

end

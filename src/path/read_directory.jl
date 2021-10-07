function read_directory(di::String; so = true, jo = true)::Vector{String}

    di = get_absolute(di)

    return [
        na for na in readdir(di; sort = so, join = jo) if !startswith(splitdir(na)[2], '.')
    ]

end

export read_directory

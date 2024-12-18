using Omics

using Test: @test

# ----------------------------------------------------------------------------------------------- #

using KernelDensity: kde

using Random: seed!

# ---- #

const UG = 16

# ---- #

for nu_ in ([1, 2, 2, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5, 5, 6, 6, 6, 6, 7, 7, 7, 8, 8, 9],)

    gr_, co_ = Omics.Density.coun(nu_, UG)

    kd = kde(nu_; boundary = extrema(nu_), npoints = UG)

    @test gr_ === kd.x

    Omics.Plot.plot(
        "",
        (Dict("type" => "bar", "y" => co_, "x" => gr_),),
        Dict("xaxis" => Dict("tickvals" => gr_)),
    )

    Omics.Plot.plot(
        "",
        (Dict("type" => "bar", "y" => kd.density, "x" => kd.x),),
        Dict("xaxis" => Dict("tickvals" => kd.x)),
    )

end

# ---- #

# 412.500 ns (2 allocations: 192 bytes)
# 3.802 μs (36 allocations: 1.89 KiB)
# 1.892 μs (2 allocations: 192 bytes)
# 5.653 μs (36 allocations: 2.66 KiB)
# 20.209 μs (2 allocations: 192 bytes)
# 25.083 μs (38 allocations: 9.70 KiB)
# 302.708 μs (2 allocations: 192 bytes)
# 423.042 μs (38 allocations: 79.95 KiB)
for ur in (10, 100, 1000, 10000)

    seed!(20241023)

    nu_ = randn(ur)

    @btime Omics.Density.coun($nu_, UG)

    @btime kde($nu_; boundary = $(extrema(nu_)), npoints = UG)

end

# ---- #

for (n1_, n2_) in (([1, 2, 3, 4, 6], [2, 4, 8, 16, 64]),)

    g1_, g2_, co = Omics.Density.coun(n1_, n2_, UG, UG)

    kd = kde((n1_, n2_); boundary = (extrema(n1_), extrema(n2_)), npoints = (UG, UG))

    @test g1_ == kd.x

    @test g2_ == kd.y

    Omics.Plot.plot_heat_map("", co; ro_ = g1_, co_ = g2_)

    Omics.Plot.plot_heat_map("", kd.density; ro_ = kd.x, co_ = kd.y)

end

# ---- #

# 879.808 ns (3 allocations: 2.08 KiB)
# 13.959 μs (54 allocations: 13.23 KiB)
# 3.927 μs (3 allocations: 2.08 KiB)
# 17.750 μs (54 allocations: 14.77 KiB)
# 45.625 μs (3 allocations: 2.08 KiB)
# 56.166 μs (57 allocations: 28.84 KiB)
# 627.459 μs (3 allocations: 2.08 KiB)
# 902.417 μs (57 allocations: 169.34 KiB)
for ur in (10, 100, 1000, 10000)

    seed!(20241023)

    n1_ = randn(ur)

    n2_ = randn(ur)

    @btime Omics.Density.coun($n1_, $n2_, UG, UG)

    @btime kde(
        ($n1_, $n2_);
        boundary = ($(extrema(n1_)), $(extrema(n2_))),
        npoints = (UG, UG),
    )

end

@testset "WPD" begin
    x = randn(8)
    wt = wavelet(WT.haar)
    g, h = WT.makereverseqmfpair(wt, true)
    y1 = wpt(x, wt, 1)
    y2 = wpt(x, wt, 2)
    y3 = wpt(x, wt, 3)
    @test wpd(x, wt) == [x y1 y2 y3]
    
    y = Array{Float64,2}(undef, (8,4))
    wpd!(y, x, wt)
    @test y == [x y1 y2 y3]
end

@testset "SWT" begin
    x = randn(8)
    wt = wavelet(WT.db4)
    g, h = WT.makeqmfpair(wt)
    tree = maketree(x, :dwt)
    ε = [true, true, false]
    @test isdwt(sdwt(x, wt, 3), wt) ≈ x
    @test isdwt(sdwt(x, wt), wt, ε) ≈ x
    @test swpt(x, wt) == swpd(x, wt)[:,8:15]
    @test swpt(x, wt, 3) == swpd(x, wt)[:,8:15]
    @test swpt(x, wt, tree) == sdwt(x, wt)
    @test swpt(x, wt, tree) == swpt(x, h, g, tree)
    @test iswpt(swpd(x, wt), wt) ≈ x
    @test iswpt(swpd(x, wt), wt, tree) ≈ x
    @test iswpt(swpd(x, wt), wt, ε, tree) ≈ x
    @test iswpt(swpd(x, wt), wt, ε) ≈ x
end

@testset "SIWPD" begin
    # siwpd 
    x = randn(4)
    wt = wavelet(WT.haar)
    y = siwpd(x, wt, 2, 1)
    y0 = y[1,4:7]
    y1 = y[2,4:7]
    y2 = y[3,4:7]
    y3 = y[4,4:7]
    @test y0 == wpt(x, wt)
    @test !all([isdefined(y1, i) for i in 1:4])
    @test y2 == wpt(circshift(x,2), wt)
    @test !all([isdefined(y3, i) for i in 1:4])
    # make tree
    tree = [
        trues(1), 
        repeat([trues(2)],2)..., 
        repeat([BitVector([1,0,1,0])],4)...
    ]
    @test makesiwpdtree(4, 2, 1) == tree
end

@testset "ACWT" begin
    # acwt (1D)
    x₁ = randn(8)
    y₁ = acdwt(x₁, wavelet(WT.haar))
    @test iacdwt(y₁) ≈ x₁

    # acwt (2D)
    x₂ = randn(8,8)
    y₂ = acdwt(x₂, wavelet(WT.haar))
    @test iacdwt(y₂) ≈ x₂
    
    # acwpt
    tree = maketree(x₁)
    y₃ = acwpd(x₁, wavelet(WT.haar))
    @test y₃[:,8] == y₁[:,1]
    @test iacwpt(y₃, tree) ≈ x₁
end

@testset "Transform All" begin
    x = randn(8)
    xₙ = [x x x]
    wt = wavelet(WT.haar)
    
    # dwt
    y = dwt(x, wt)
    @test dwtall(xₙ, wt) == [y y y]

    # wpt
    y = wpt(x, wt)
    @test wptall(xₙ, wt) == [y y y]

    # wpd
    y = [x wpt(x,wt,1) wpt(x,wt,2)]
    @test wpdall(xₙ, wt, 2) == cat(y,y,y, dims=3)
end
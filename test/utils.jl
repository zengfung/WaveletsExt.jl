@testset "Indexing" begin
    @test left(1) == 2
    @test right(1) == 3
    @test nodelength(8,2) == 2

    tree = BitVector([1, 1, 1, 1, 0, 1, 0])
    @test getleaf(tree) == BitVector([0,0,0,0,1,0,1,1,1,0,0,1,1,0,0]) 

    tree = BitVector([1,0,0])
    x = randn(4)
    @test coarsestscalingrange(x, tree) == 1:2
    @test coarsestscalingrange(4, tree) == 1:2
    @test coarsestscalingrange(x, tree, true) == (1:4, 2)
    @test coarsestscalingrange(4, tree, true) == (1:4, 2)
    @test finestdetailrange(x, tree) == 3:4
    @test finestdetailrange(4, tree) == 3:4
    @test finestdetailrange(x, tree, true) == (1:4, 3)
    @test finestdetailrange(4, tree, true) == (1:4, 3)
end

@testset "Error Rates" begin
    x₀ = ones(5)
    x = 2*ones(5)
    @test relativenorm(x, x₀) == 1
    @test relativenorm(x, x₀, 1.0) == 1
    @test psnr(x, x₀) == 0
    @test snr(x, x₀) == 0
    @test ssim(x, x₀) == assess_ssim(x, x₀)
end

@testset "Generate Signals" begin
    x = [1, 0, 0, 0]
    @test duplicatesignals(x, 2, 1) == [1 0; 0 1; 0 0; 0 0]
    @test duplicatesignals(x, 2, 1, true) != duplicatesignals(x, 2, 1)
    @test duplicatesignals(x, 2, 1, true, 0.5) != duplicatesignals(x, 2, 1)

    @test length(generatesignals(:blocks, 5)) == 32
    @test length(generatesignals(:bumps, 5)) == 32
    @test length(generatesignals(:doppler, 5)) == 32
    @test length(generatesignals(:heavysine, 5)) == 32
    @test length(generatesignals(:quadchirp, 5)) == 32
    @test length(generatesignals(:mishmash, 5)) == 32
    @test_throws ArgumentError generatesignals(:fail, 5)

    @test typeof(ClassData(:tri, 5, 5, 5)) == ClassData
    @test typeof(ClassData(:cbf, 5, 5, 5)) == ClassData
    @test_throws ArgumentError ClassData(:fail, 5, 5, 5)

    @test size(generateclassdata(ClassData(:tri, 5, 5, 6))[1]) == (32,16)
    @test size(generateclassdata(ClassData(:cbf, 5, 5, 5))[1]) == (128,15)
    @test_nowarn generateclassdata(ClassData(:tri, 5, 5, 5), true)
end
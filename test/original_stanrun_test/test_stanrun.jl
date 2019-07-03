using StanSample, Test

@testset "StanRun cmdstan run and results" begin
    # setup environment
    MODELDIR = mktempdir()
    SAMPLEDIR = mktempdir()
    SRC = joinpath(MODELDIR, "test.stan")
    cp(joinpath(@__DIR__, "test.stan"), SRC)

    # run a model
    model = StanModel(SRC)
    @test repr(model) ==
        "Stan model at $(SRC)\n    (CmdStan home: $(StanRun.get_cmdstan_home()))"
    exec_path = StanRun.ensure_executable(model)
    @test isfile(exec_path)
    n_chains = 5
    OUTPUT_BASE = joinpath(SAMPLEDIR, "test")
    time_before = time()
    @test stan_compile(model) ≡ nothing
    chains = stan_sample(model, (N = 100, x = randn(100)), 5; output_base = OUTPUT_BASE)
    for (sample, logfile) in chains
        @test ctime(sample) ≥ time_before
        @test ctime(sample) ≥ time_before
    end
    @test first.(chains) == sort(StanRun.find_samples(OUTPUT_BASE)) ==
        [joinpath(SAMPLEDIR, "test_chain_$(i).csv") for i in 1:n_chains]
end

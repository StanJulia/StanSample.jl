using StanSample, Test

@testset "cmdstan run and results" begin
    # setup environment
    MODELDIR = mktempdir()
    SAMPLEDIR = mktempdir()
    SRC = joinpath(MODELDIR, "test.stan")
    cp(joinpath(@__DIR__, "test.stan"), SRC)

    # run a model
    model = StanModel(SRC)
    @test repr(model) ==
        "Stan model at $(SRC)\n    (CmdStan home: $(StanSample.get_cmdstan_home()))"
    exec_path = StanSample.ensure_executable(model)
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
    @test first.(chains) == sort(StanSample.find_samples(OUTPUT_BASE)) ==
        [joinpath(SAMPLEDIR, "test_chain_$(i).csv") for i in 1:n_chains]
end

@testset "unset cmdstan environment" begin
    withenv("JULIA_CMDSTAN_HOME" => nothing) do
        @test_throws ErrorException StanSample.get_cmdstan_home()
    end
end

@testset "model error and message" begin
    model = StanModel(joinpath(@__DIR__, "test_incorrect.stan"))
    try
        stan_compile(model)
    catch e
        @test e isa StanSample.StanModelError
        @test occursin("Variable \"x\" does not exist", e.message)
        io = IOBuffer()
        showerror(io, e)
        e_repr = String(take!(io))
        @test occursin("error when compiling", e_repr)
    end
end

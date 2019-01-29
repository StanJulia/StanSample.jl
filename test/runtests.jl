using StanRun, Test

MODELDIR = mktempdir()
SAMPLEDIR = mktempdir()
SRC = joinpath(MODELDIR, "test.stan")
cp(joinpath(@__DIR__, "test.stan"), SRC)

model = StanModel(SRC)
exec_path = StanRun.ensure_executable(model)
@test isfile(exec_path)
n_chains = 5
OUTPUT_BASE = joinpath(SAMPLEDIR, "test")
chains = stan_sample(model, (N = 100, x = randn(100)), 5; output_base = OUTPUT_BASE)
@test chains == sort(StanRun.find_samples(OUTPUT_BASE)) ==
    [joinpath(SAMPLEDIR, "test_chain_$(i).csv") for i in 1:n_chains]

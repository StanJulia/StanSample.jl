using StanSample, Test

TestDir = @__DIR__
cd(TestDir)

include(joinpath("..", "..", "examples", "Bernoulli", "bernoulli.jl"))
bernoulli_init = (N = 10, y = [0, 1, 0, 1, 0, 0, 0, 0, 0, 1],)
test_fname = joinpath(TestDir, "stan_sample_test_data.R")

ProjDir = joinpath("..", "..", "examples", "Bernoulli")
!isdir(ProjDir*"/tmp") && mkdir(ProjDir*"/tmp")

if isdir(stanmodel.tmpdir)
  for i in 1:4
    isfile(joinpath(stanmodel.tmpdir, "bernoulli_data_$i.R")) &&
      rm(joinpath(stanmodel.tmpdir, "bernoulli_data_$i.R"))
    isfile(joinpath(stanmodel.tmpdir, "bernoulli_init_$i..R")) &&
      rm(joinpath(stanmodel.tmpdir, "bernoulli_init_$i..R"))
    end
end

stan_sample(stanmodel, bernoulli_init, bernoulli_data, 4)

@test isfile(joinpath(stanmodel.tmpdir, "bernoulli_data_4.R"))
@test isfile(joinpath(stanmodel.tmpdir, "bernoulli_init_4.R"))

if isdir(stanmodel.tmpdir)
  for i in 1:4
    isfile(joinpath(stanmodel.tmpdir, "bernoulli_data_$i.R")) &&
      rm(joinpath(stanmodel.tmpdir, "bernoulli_data_$i.R"))
    isfile(joinpath(stanmodel.tmpdir, "bernoulli_init_$i..R")) &&
      rm(joinpath(stanmodel.tmpdir, "bernoulli_init_$i..R"))
    end
end

stan_sample(stanmodel, bernoulli_init, test_fname, 4)

@test isfile(joinpath(ProjDir, "tmp", "bernoulli_data_4.R"))
@test isfile(joinpath(ProjDir, "tmp", "bernoulli_init_4.R"))


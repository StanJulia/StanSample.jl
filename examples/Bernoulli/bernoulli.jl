######### CmdStan sample example  ###########

using StanSample

ProjDir = @__DIR__
cd(ProjDir) #do

  bernoulli_model = "
  data { 
    int<lower=1> N; 
    int<lower=0,upper=1> y[N];
  } 
  parameters {
    real<lower=0,upper=1> theta;
  } 
  model {
    theta ~ beta(1,1);
    y ~ bernoulli(theta);
  }
  ";

  bernoulli_data = Dict("N" => 10, "y" => [0, 1, 0, 1, 0, 0, 0, 0, 0, 1])

  tmpdir = joinpath(ProjDir, "tmp")
  stanmodel = CmdStanSampleModel("bernoulli", bernoulli_model;
    tmpdir = tmpdir,
    method = StanSample.Sample(adapt=StanSample.Adapt(delta=0.85)))
  
  stan_sample(stanmodel, bernoulli_data, 4)
  
  #=
  @show stan_sample(stanmodel.sm, bernoulli_nt, 4)
  println()
  @show stan_sample(stanmodel.sm, bernoulli_data[1], 4)  
  println()
  @show stan_sample(stanmodel.sm, bernoulli_data, 4)  
  println()
  @show stan_sample(stanmodel.sm, bernoulli_data[1:3], 4)  
  println()
  
  nt = read_samples(stanmodel.output_base*"_chain_1.csv")
  
  a3d, cnames = read_stanrun_samples(stanmodel.output_base, "_chain")
  global chns = convert_a3d(a3d, cnames, Val(:mcmcchains); start=1)
  cdf = describe(chns)
  =#
  
  #end # cd

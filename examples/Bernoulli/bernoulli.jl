######### CmdStan program example  ###########

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

  bernoulli_data = [
    Dict("N" => 10, "y" => [0, 1, 0, 1, 0, 0, 0, 0, 0, 1]),
    Dict("N" => 10, "y" => [0, 1, 0, 0, 0, 0, 1, 0, 0, 1]),
    Dict("N" => 10, "y" => [0, 0, 0, 0, 0, 0, 1, 0, 1, 1]),
    Dict("N" => 10, "y" => [0, 0, 0, 1, 0, 0, 0, 1, 0, 1])
  ]
  bernoulli_nt = (N=10, y=[0,1,0,1,0,0,0,0,0,1])

  tmpdir = joinpath(ProjDir, "tmp")
  if !isdir(tmpdir)
    mkdir(tmpdir)
  end
  #tmpdir = mktempdir()
  
  update_model_file(joinpath(tmpdir, "bernoulli.stan"), strip(bernoulli_model))
  sm = StanModel(joinpath(tmpdir, "bernoulli.stan"))
  
  update_settings((delta=0.85,))
  
  stan_compile(sm)
  println()
  @show stan_sample(sm, bernoulli_nt, 4)
  println()
  @show stan_sample(sm, bernoulli_data[1], 4)  
  println()
  @show stan_sample(sm, bernoulli_data, 4)  
  println()
  @show stan_sample(sm, bernoulli_data[1:3], 4)  
  println()
  
  output_base = default_output_base(sm)
  nt = read_samples(output_base*"_chain_1.csv")
  println()
  
  a3d, cnames = read_stanrun_samples(output_base, "_chain")
  chns = convert_a3d(a3d, cnames, Val(:mcmcchains); start=1)
  cdf = describe(chns)
  
#end # cd

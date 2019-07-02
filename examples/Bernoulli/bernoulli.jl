######### CmdStan sample example  ###########

using StanSample

ProjDir = @__DIR__
cd(ProjDir) do

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
  
  # Keep tmpdir identical across multiple runs to prevent re-compilation
  tmpdir = joinpath(ProjDir, "tmp")
  stanmodel = CmdStanSampleModel("bernoulli", bernoulli_model;
    tmpdir = tmpdir,
    method = StanSample.Sample(adapt=StanSample.Adapt(delta=0.85)))
  
  stan_sample(stanmodel, bernoulli_data, diagnostics=true)
  
  # Use StanSamples to read a chain in NamedTupla format
  nt = read_samples(stanmodel.output_base*"_chain_1.csv")
  
  # Convert to an MCMCChains.Chains object
  a3d, cnames = read_stanrun_samples(stanmodel.output_base, "_chain")
  global chns = convert_a3d(a3d, cnames, Val(:mcmcchains); start=1)
  
  # Describe the MCMCChains using MCMCChains statistics
  global cdf = describe(chns)
  display(cdf)
  
  # Show the output of the stansummary executable
  stan_summary(stanmodel, printsummary=true)
  
  # Show the same output in DataFrame format
  read_summary(stanmodel)
  
end # cd

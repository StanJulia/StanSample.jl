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
  
  # Keep tmpdir across multiple runs to prevent re-compilation
  tmpdir = joinpath(ProjDir, "tmp")
  
  global stanmodel = CmdStanSampleModel(
    "bernoulli", bernoulli_model; tmpdir = tmpdir,
    method = StanSample.Sample(adapt=StanSample.Adapt(delta=0.85)))
  
  stan_sample(stanmodel, bernoulli_data, diagnostics=true)
  
  # Use StanSamples to read a chain in NamedTupla format
  global nt = read_samples(stanmodel.output_base*"_chain_1.csv")
  
  # Convert to an MCMCChains.Chains object
  global chns = read_samples(stanmodel)
  
  # Describe the MCMCChains using MCMCChains statistics
  global cdf = describe(chns)
  display(cdf)
  
  # Show the same output in DataFrame format
  global sdf = read_summary(stanmodel)
  display(sdf)
  println()
  
  # Retrieve mean value of theta from the summary
  sdf[:theta, :mean]
  
end # cd

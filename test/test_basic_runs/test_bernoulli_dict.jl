######### StanSample example  ###########

using StanSample, Test

bernoulli_model = "
data { 
  int<lower=1> N; 
  array[N] int<lower=0,upper=1> y;
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

sm = SampleModel("bernoulli", bernoulli_model)
rc = stan_sample(sm, data=bernoulli_data, num_chains=4, delta=0.85)

# Fetch the cmdstan summary in sdf`
if success(rc)
	sdf = read_summary(sm)
	@test sdf[sdf.parameters .== :theta, :mean][1] ≈ 0.33 rtol=0.05

  # Included return formats

  samples = read_samples(sm)          # Return KeyesArray object
  a3d = read_samples(sm, :array)      # Return an a3d object
  df = read_samples(sm, :dataframe)   # Return a DataFrame object

  # If (and only if) MCMCChains is loaded:
  # chns = read_samples(sm, :mcmcchains)
  # See examples in directory `examples_mcmcchains`

  df
end

isdir(tmpdir) && rm(tmpdir, recursive=true)
sm = SampleModel("bernoulli", bernoulli_model, tmpdir)

rc = stan_sample(sm, data=bernoulli_data, 
  num_threads=4, num_cpp_chains=1, num_chains=4, delta=0.85)

# Fetch the cmdstan summary in sdf`
if success(rc)
  sdf = read_summary(sm)
  @test sdf[sdf.parameters .== :theta, :mean][1] ≈ 0.33 rtol=0.05

  # Included return formats

  samples = read_samples(sm)          # Return Tables object
  a3d = read_samples(sm, :array)      # Return an a3d object
  df = read_samples(sm, :dataframe)   # Return a DataFrame object

  # If (and only if) MCMCChains is loaded:
  # chns = read_samples(sm, :mcmcchains)
  # See examples in directory `examples_mcmcchains`

  df
end

######### StanSample example  ###########

using StanSample

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

# Keep tmpdir identical to prevent re-compilation
#tmpdir=joinpath(@__DIR__, "tmp")
tmpdir=mktempdir()

sm = SampleModel("bernoulli", bernoulli_model, tmpdir)

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

end

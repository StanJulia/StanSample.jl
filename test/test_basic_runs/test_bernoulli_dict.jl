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
stanmodel = CmdStanSampleModel(
  "bernoulli", bernoulli_model; tmpdir = tmpdir,
  method = StanSample.Sample(adapt=StanSample.Adapt(delta=0.85)))

stan_sample(stanmodel, data=bernoulli_data, n_chains=6, diagnostics=true)

# Use StanSamples to read the chains in NamedTupla format
nt = read_samples(stanmodel.sm)

# Convert to an MCMCChains.Chains object
chns = read_samples(stanmodel)

# Describe the MCMCChains using MCMCChains statistics
cdf = describe(chns)
display(cdf)

# Show the output of the stansummary executable
stan_summary(stanmodel, printsummary=true)

# Fetch the same output in the `sdf` ChainDataFrame
sdf = read_summary(stanmodel)
  
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

stanmodel = SampleModel(
  "bernoulli", bernoulli_model;
  method = StanSample.Sample(adapt=StanSample.Adapt(delta=0.85)),
  tmpdir=tmpdir)

rc = stan_sample(stanmodel, data=bernoulli_data, n_chains=6)

# Fetch the same output in the `sdf` ChainDataFrame
if success(rc)
	sdf = read_summary(stanmodel)
end

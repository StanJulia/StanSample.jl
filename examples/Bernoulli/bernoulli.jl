######### StanSample Bernoulli example  ###########

using StanSample, MCMCChains

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
#tmpdir = joinpath(@__DIR__, "tmp")

sm = SampleModel("bernoulli", bernoulli_model;
  method = StanSample.Sample(save_warmup=true,
    adapt = StanSample.Adapt(delta = 0.85)),
  #tmpdir = tmpdir,
)

rc = stan_sample(sm; data=bernoulli_data)

if success(rc)
  # Convert to an MCMCChains.Chains object
  chns = read_samples(sm)

  # Describe the MCMCChains using MCMCChains statistics
  # By default, just show the `parameters` section.
  # Use `chns.name_map` to see all sections.
  cdf = show(chns)

  # Describe the `internals` section statistics
  icdf = describe(chns, sections=[:internals])
  display(icdf)

  # Show the same output in DataFrame format
  #stan_summary(sm)
  sdf = read_summary(sm)
  display(sdf)
end

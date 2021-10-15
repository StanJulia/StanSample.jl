######### StanSample Bernoulli example  ###########

using AxisKeys
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

# Keep tmpdir across multiple runs to prevent re-compilation
tmpdir = joinpath(@__DIR__, "tmp")

sm = SampleModel("bernoulli", bernoulli_model, [6];
  method = StanSample.Sample(
    save_warmup=false,                           # Default
    thin=1,
    adapt = StanSample.Adapt(delta = 0.85)),
  tmpdir = tmpdir,
);

rc = stan_sample(sm; data=bernoulli_data, seed=123);

if success(rc)
  chns = read_samples(sm)
  chns |> display
end

######### StanSample Bernoulli example  ###########

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

data = Dict("N" => 10, "y" => [0, 1, 0, 1, 0, 0, 0, 0, 0, 1])

# Keep tmpdir across multiple runs to prevent re-compilation
tmpdir = joinpath(@__DIR__, "tmp")

sm = SampleModel("bernoulli", bernoulli_model;
  tmpdir = tmpdir
);

rc = stan_sample(sm; data);

if success(rc)
  (samples, cnames) = read_samples(sm, :array; return_parameters=true)

  ka = read_samples(sm)
  ka |> display
  println()

  sdf = read_summary(sm)
  sdf |> display
end

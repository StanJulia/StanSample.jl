######### StanSample Bernoulli example  ###########

using StanSample

ProjDir = @__DIR__

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

sm = SampleModel("bernoulli", bernoulli_model, tmpdir);

sm |> display

rc = stan_sample(sm; data, num_threads=4, num_cpp_chains=4, num_chains=2, seed=12);

if success(rc)
  st = read_samples(sm)
  display(st)
  println()
  display(read_samples(sm, :dataframe))
end


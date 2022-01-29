using DataFrames
using StanSample, Test

ProjDir = @__DIR__
cd(ProjDir)

gq = "
  data {
    int<lower=0> N;
    int<lower=0> y[N];
  }
  parameters {
    real<lower=0.00001> Theta;
  }
  model {
    Theta ~ gamma(4, 1000);
    for (n in 1:N)
      y[n] ~ exponential(Theta);
  }
  generated quantities{
    real y_pred;
    y_pred = exponential_rng(Theta);
  }
";

data = Dict(
  "N" => 3,
  "y" => [100, 950, 450]
);

sm = SampleModel("Generate_quantities", gq, joinpath(@__DIR__, "tmp"));

rc = stan_sample(sm; data)

if success(rc)
  df = stan_generate_quantities(sm, 1, "1_1")
  df |> display
end

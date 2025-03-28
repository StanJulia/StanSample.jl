######### StanSample Bernoulli example  ###########

using StanSample

bernoulli_model = "
data {
  int N;
  array[N] int y;
}
parameters {
  real<lower=0,upper=1> theta;
}
model {
  theta ~ beta(1,1);
  y ~ bernoulli(theta);
}
";

fl = joinpath(tempdir(), "bernoulli.diag_e.json")

open(fl, "w") do f
  write(f, "{ \"inv_metric\" : [0.296291] }")
end


data = Dict("N" => 10, "y" => [0, 1, 0, 1, 0, 0, 0, 0, 0, 1])
sm = SampleModel("bernoulli", bernoulli_model);

rc = stan_sample(sm; data, algorithm=:hmc, stepsize=0.9, metric_file=fl);

if success(rc)
  (samples, cnames) = read_samples(sm, :array; return_parameters=true)

  ka = read_samples(sm, :keyedarray)
  ka |> display
  println()

  sdf = read_summary(sm)
  sdf |> display
end

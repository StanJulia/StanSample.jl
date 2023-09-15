######### StanSample Bernoulli example  ###########

using StanSample, DataFrames, Test

ProjDir = @__DIR__

bernoulli_model = "
data {
  int<lower=1> N;
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

data = Dict("N" => 10, "y" => [0, 1, 0, 1, 0, 0, 0, 0, 0, 1])
isdir(tmpdir) &&  rm(tmpdir; recursive=true)
sm = SampleModel("bernoulli", bernoulli_model);
rc1 = stan_sample(sm; data, sig_figs=18);

if success(rc1)
  st = read_samples(sm)
  #display(DataFrame(st))
end
@test size(DataFrame(st), 1) == 4000

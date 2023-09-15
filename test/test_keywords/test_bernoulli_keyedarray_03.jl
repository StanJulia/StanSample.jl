######### StanSample Bernoulli example  ###########

using AxisKeys
using StanSample

bernoulli_model = "
data {
  int<lower=1> N;
  array[N] int<lower=0,upper=1> y;
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

sm = SampleModel("bernoulli", bernoulli_model);
rc = stan_sample(sm; data=bernoulli_data,
    num_threads=6, num_cpp_chains=1, num_chains=6, seed=123);

if success(rc)
  chns = read_samples(sm)
  chns = display
end

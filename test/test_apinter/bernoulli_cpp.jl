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

sm = SampleModel("bernoulli", bernoulli_model);
rc1 = stan_sample(sm; data);

if success(rc1)
  st = read_samples(sm)
  #display(DataFrame(st))
end
@test size(DataFrame(st), 1) == 4000

sm = SampleModel("bernoulli", bernoulli_model);
rc2 = stan_sample(sm; use_cpp_chains=true, data);

if success(rc2)
  st = read_samples(sm)
  #display(DataFrame(st))
end
@test size(DataFrame(st), 1) == 4000

sm = SampleModel("bernoulli", bernoulli_model);
rc3 = stan_sample(sm; use_cpp_chains=true, check_num_chains=false,
    num_cpp_chains=2, num_julia_chains=2, data);

if success(rc3)
  st = read_samples(sm)
  #display(DataFrame(st))
end
@test size(DataFrame(st), 1) == 4000

sm = SampleModel("bernoulli", bernoulli_model);
rc4 = stan_sample(sm; use_cpp_chains=true, check_num_chains=false,
  num_cpp_chains=4, num_julia_chains=4, data);

if success(rc4)
  st = read_samples(sm)
  #display(DataFrame(st))
end
@test size(DataFrame(st), 1) == 16000

sm = SampleModel("bernoulli", bernoulli_model);
rc4 = stan_sample(sm; use_cpp_chains=true, check_num_chains=false,
  num_cpp_chains=1, num_julia_chains=4, data);

if success(rc4)
  st = read_samples(sm)
  #display(DataFrame(st))
end
@test size(DataFrame(st), 1) == 4000

sm = SampleModel("bernoulli", bernoulli_model);
rc4 = stan_sample(sm; use_cpp_chains=true, check_num_chains=false,
  num_cpp_chains=4, num_julia_chains=1, data);

if success(rc4)
  st = read_samples(sm)
  #display(DataFrame(st))
end
@test size(DataFrame(st), 1) == 4000

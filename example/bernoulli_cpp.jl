######### StanSample Bernoulli example  ###########

using StanSample, DataFrames

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
tmpdir = joinpath(ProjDir, "tmp")
isdir(tmpdir) &&  rm(tmpdir; recursive=true)
sm = SampleModel("bernoulli", bernoulli_model, tmpdir);
rc1 = stan_sample(sm; data);

if success(rc1)
  post = read_samples(sm, :dataframes)

  display(available_chains(sm))

  second_chain = rand(2:sm.num_chains)
  available_chains(sm)[:suffix][second_chain] |> display
  @assert post[second_chain].theta[1:5] == post[second_chain].theta[1:5]
  @assert post[1].theta[1:5] !== post[second_chain].theta[1:5]
  zip.(post[1].theta[1:5], post[second_chain].theta[1:5]) |> display
end

isdir(tmpdir) && rm(tmpdir; recursive=true)
sm = SampleModel("bernoulli", bernoulli_model, tmpdir);
rc2 = stan_sample(sm; use_cpp_chains=true, data);

if success(rc2)
  post = read_samples(sm, :dataframes)

  display(available_chains(sm))

  second_chain = rand(2:sm.num_chains)
  available_chains(sm)[:suffix][second_chain] |> display
  @assert post[second_chain].theta[1:5] == post[second_chain].theta[1:5]
  @assert post[1].theta[1:5] !== post[second_chain].theta[1:5]
  zip.(post[1].theta[1:5], post[second_chain].theta[1:5]) |> display
end

isdir(tmpdir) && rm(tmpdir; recursive=true)
sm = SampleModel("bernoulli", bernoulli_model, tmpdir);
rc2_1 = stan_sample(sm; num_cpp_chains=5, use_cpp_chains=true, data);

if success(rc2_1)
  post = read_samples(sm, :dataframes)

  display(available_chains(sm))

  second_chain = rand(2:sm.num_chains)
  available_chains(sm)[:suffix][second_chain] |> display
  @assert post[second_chain].theta[1:5] == post[second_chain].theta[1:5]
  @assert post[1].theta[1:5] !== post[second_chain].theta[1:5]
  zip.(post[1].theta[1:5], post[second_chain].theta[1:5]) |> display
end


isdir(tmpdir) && rm(tmpdir; recursive=true)
sm = SampleModel("bernoulli", bernoulli_model, tmpdir);
rc3 = stan_sample(sm; use_cpp_chains=true, check_num_chains=false,
    num_cpp_chains=2, num_julia_chains=2, data);

if success(rc3)
  post = read_samples(sm, :dataframes)

  display(available_chains(sm))

  second_chain = rand(2:sm.num_chains)
  available_chains(sm)[:suffix][second_chain] |> display
  @assert post[second_chain].theta[1:5] == post[second_chain].theta[1:5]
  @assert post[1].theta[1:5] !== post[second_chain].theta[1:5]
  zip.(post[1].theta[1:5], post[second_chain].theta[1:5]) |> display
end

isdir(tmpdir) && rm(tmpdir; recursive=true)
sm = SampleModel("bernoulli", bernoulli_model, tmpdir);
rc4 = stan_sample(sm; use_cpp_chains=true, check_num_chains=false,
  num_cpp_chains=4, num_julia_chains=4, data);

if success(rc4)
  post = read_samples(sm, :dataframes)

  display(available_chains(sm))

  second_chain = rand(2:sm.num_chains)
  available_chains(sm)[:suffix][second_chain] |> display
  @assert post[second_chain].theta[1:5] == post[second_chain].theta[1:5]
  @assert post[1].theta[1:5] !== post[second_chain].theta[1:5]
  zip.(post[1].theta[1:5], post[second_chain].theta[1:5]) |> display
end

isdir(tmpdir) && rm(tmpdir; recursive=true)
sm = SampleModel("bernoulli", bernoulli_model, tmpdir);
rc4 = stan_sample(sm; use_cpp_chains=true, check_num_chains=false,
  num_cpp_chains=1, num_julia_chains=4, data);

if success(rc4)
  post = read_samples(sm, :dataframes)

  display(available_chains(sm))

  second_chain = rand(2:sm.num_chains)
  available_chains(sm)[:suffix][second_chain] |> display
  @assert post[second_chain].theta[1:5] == post[second_chain].theta[1:5]
  @assert post[1].theta[1:5] !== post[second_chain].theta[1:5]
  zip.(post[1].theta[1:5], post[second_chain].theta[1:5]) |> display
end

isdir(tmpdir) && rm(tmpdir; recursive=true)
sm = SampleModel("bernoulli", bernoulli_model, tmpdir);
rc4 = stan_sample(sm; use_cpp_chains=true, check_num_chains=false,
  num_cpp_chains=4, num_julia_chains=1, data);

if success(rc4)
  post = read_samples(sm, :dataframes)

  display(available_chains(sm))

  second_chain = rand(2:sm.num_chains)
  available_chains(sm)[:suffix][second_chain] |> display
  @assert post[second_chain].theta[1:5] == post[second_chain].theta[1:5]
  @assert post[1].theta[1:5] !== post[second_chain].theta[1:5]
  zip.(post[1].theta[1:5], post[second_chain].theta[1:5]) |> display
end


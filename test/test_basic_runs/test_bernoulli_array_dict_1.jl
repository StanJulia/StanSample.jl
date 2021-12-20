######### StanSample example  ###########

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

bernoulli_data = [
  Dict("N" => 10, "y" => [0, 1, 0, 1, 0, 0, 0, 0, 0, 1]),
  Dict("N" => 10, "y" => [0, 1, 0, 0, 1, 0, 0, 0, 0, 1]),
  Dict("N" => 10, "y" => [0, 1, 0, 1, 0, 0, 0, 0, 1, 0]),
  Dict("N" => 10, "y" => [0, 0, 0, 1, 0, 0, 1, 0, 0, 1]),
]

stanmodel = SampleModel("bernoulli", bernoulli_model)
rc = stan_sample(stanmodel; data=bernoulli_data, delta=0.85, num_threads=6)
if success(rc)

  # Fetch the same output in the `sdf` ChainDataFrame
  sdf = read_summary(stanmodel)

  @test sdf[sdf.parameters .== :theta, :mean][1] ≈ 0.33 rtol=0.05
  
end
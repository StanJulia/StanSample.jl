using StanSample
using MCMCChains
using Random

seed = 350
Random.seed!(seed)
n_obs = 50
y = randn(n_obs)

stan_data_2 = Dict("y" => y, "n_obs" => n_obs);
stan_data= (y=y, n_obs=n_obs);

model = "
data{
     // total observations
     int n_obs;
     // observations
    vector[n_obs] y;
}

parameters {
    real mu;
    real<lower=0> sigma;
}

model {
    mu ~ normal(0, 1);
    sigma ~ gamma(1, 1);
    y ~ normal(mu, sigma); 
}";

tmpdir = pwd()*"/tmp"
sm = SampleModel("temp", model, tmpdir)
rc = stan_sample(sm; data=stan_data_2)
read_samples(sm, :mcmcchains) |> display

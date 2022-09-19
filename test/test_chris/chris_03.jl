cd(@__DIR__)
using StanSample, Random, MCMCChains
tempdir = pwd() * "/tmp"
####################################################################
#                                     Generate Data
####################################################################
seed = 350
Random.seed!(seed)
n_obs = 50
y = randn(n_obs)

stan_data = Dict(
    "y" => y,
    "n_obs" => n_obs)

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
}"
sm_01 = SampleModel("temp", model, tempdir)

#=
# run the sampler
rc_01 = stan_sample(
    sm_01;
    data = stan_data,
    seed,
    num_chains = 4,
    num_samples = 1000,
    num_warmups = 1000
)
=#

#if success(rc_01)
     post_01 = read_samples(sm_01, :array)
     mean(post_01; dims=1) |> display
#end

sm_02 = SampleModel("temp", model, tempdir)
#if success(rc_01)
     post_02 = read_samples(sm_02, :array)
     mean(post_02; dims=1) |> display
#end

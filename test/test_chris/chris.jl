cd(@__DIR__)
using Pkg
Pkg.activate("..")
using StanSample, SequentialSamplingModels, Random, MCMCChains
using StatsPlots, ACTRModels, DataFrames
include("functions.jl")
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
####################################################################
#                                     Load Model
####################################################################
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
stan_model = SampleModel("temp", model, tempdir)
######################################################################
#                                  estimate parameters
######################################################################
# run the sampler
stan_sample(
    stan_model;
    data = stan_data,
    seed,
    num_chains = 4,
    num_samples = 1000,
    num_warmups = 1000,
    save_warmup = false
)

samples = read_samples(stan_model, :mcmcchains)

Now run everything except for the sampler:

######################################################################
#                               set environment variables
######################################################################
# replace with your local directory
ENV["CMDSTAN_HOME"] = "/home/dfish/cmdstan"
######################################################################
#                                  load packages
######################################################################
cd(@__DIR__)
using Pkg
Pkg.activate("..")
using StanSample, SequentialSamplingModels, Random, MCMCChains
using StatsPlots, ACTRModels, DataFrames
include("functions.jl")
tempdir = pwd() * "/tmp"
#######################################################################
#                                     Generate Data
#######################################################################
seed = 350
Random.seed!(seed)
n_obs = 50
y = randn(n_obs)

stan_data = Dict(
    "y" => y,
    "n_obs" => n_obs)
########################################################################
#                                     Load Model
########################################################################
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
stan_model = SampleModel("temp", model, tempdir)
samples = read_samples(stan_model, :mcmcchains)
Results

julia> samples = read_samples(stan_model, :mcmcchains)
Chains MCMC chain (1000×2×4 Array{Float64, 3}):

Iterations        = 1:1:1000
Number of chains  = 4
Samples per chain = 1000
parameters        = mu, sigma
internals         = 

Summary Statistics
  parameters      mean       std   naive_se      mcse       ess      rhat 
      Symbol   Float64   Float64    Float64   Float64   Float64   Float64 

          mu   -0.0554    0.1159     0.0018    0.0122   11.4043    1.8670
       sigma    0.2252    0.3927     0.0062    0.0494    8.1135    9.3601

Quantiles
  parameters      2.5%     25.0%     50.0%     75.0%     97.5% 
      Symbol   Float64   Float64   Float64   Float64   Float64 

          mu   -0.3866    0.0000    0.0000    0.0000    0.0000
       sigma    0.0000    0.0000    0.0000    0.1700    1.0135

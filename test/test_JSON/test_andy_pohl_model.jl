ProjDir = @__DIR__
using StanSample
using DataFrames
using Random, Distributions


# Dimensions
n1 = 1;
n2 = 2;
n3 = 3;
# Number of observations
N = 500;

# True values
σ = 0.01;
μ₁ = [1.0, 2.0, 3.0];
μ₂ = [10, 20, 30];

μ = Array{Float32}(undef, n1, n2, n3);
μ[1, 1, :] = μ₁;
μ[1, 2, :] = μ₂;

# Observations
y = Array{Float32}(undef, N, n1, n2, n3);
for i in 1:N
    for j in 1:n1
        for k in 1:n2
            for l in 1:n3
                y[i, j, k, l] = rand(Normal(μ[j, k, l], σ))
            end
        end
    end
end

# In below Stan Language program, the definition of y
# could also be: `array[N, n1, n2] vector[n3] y;

mdl = "
data {
    int<lower=1> N;
    int<lower=1> n1;
    int<lower=1> n2;
    int<lower=1> n3;
    array[N, n1, n2, n3] real y;
}

parameters {
    array[n1, n2] vector[n3] mu;
    real<lower=0> sigma;
}
model {
    // Priors
    sigma ~ inv_gamma(0.01, 0.01);
    for (i in 1:n1) {
        for (j in 1:n2) {
            mu[i, j] ~ normal(rep_vector(0, n3), 1e6);
        }
    }

    // Model
    for (i in 1:N){
        for(j in 1:n1){
            for(k in 1:n2){
                y[i, j, k] ~ normal(mu[j, k], sigma);
            }
        }
    }
}
"

stan_data = Dict(
    "y" => y,
    "N" => N,
    "n1" => n1,
    "n2" => n2,
    "n3" => n3,
);

tmpdir = joinpath(ProjDir, "tmp")
isdir(tmpdir) && rm(tmpdir; recursive=true)
stan_model = SampleModel("multidimensional_inference", mdl, tmpdir)
stan_sample(
    stan_model;
    data=stan_data,
    seed=123,
    num_chains=4,
    num_samples=1000,
    num_warmups=1000,
    save_warmup=false
)

samps = read_samples(stan_model, :dataframe)
println(describe(samps))
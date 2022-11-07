using CSV, DataFrames, NamedTupleTools
using StanSample
using InferenceObjects
using PosteriorDB

# the posteriordb part, getting model code and data

posterior_name = "diamonds-diamonds"
pdb = database()
post = posterior(pdb, posterior_name)
model_data = Dict(string(k) => v for (k, v) in load_values(dataset(post)))
model_code = implementation(model(post), "stan")

stan_schools = """
data {
    int<lower=0> J;
    real y[J];
    real<lower=0> sigma[J];
}

parameters {
    real mu;
    real<lower=0> tau;
    real theta_tilde[J];
}

transformed parameters {
    real theta[J];
    for (j in 1:J)
        theta[j] = mu + tau * theta_tilde[j];
}

model {
    mu ~ normal(0, 5);
    tau ~ cauchy(0, 5);
    theta_tilde ~ normal(0, 1);
    y ~ normal(theta, sigma);
}

generated quantities {
    vector[J] log_lik;
    vector[J] y_hat;
    for (j in 1:J) {
        log_lik[j] = normal_lpdf(y[j] | theta[j], sigma[j]);
        y_hat[j] = normal_rng(theta[j], sigma[j]);
    }
}
""";

data = Dict(
    "J" => 8,
    "y" => [28.0, 8.0, -3.0, 7.0, -1.0, 1.0, 18.0, 12.0],
    "sigma" => [15.0, 10.0, 16.0, 11.0, 9.0, 11.0, 10.0, 18.0]
)

# Sample using cmdstan

# the stan part
tmpdir = joinpath(pwd(), "test", "test_inferencedata", "tmp")
m_schools = SampleModel("eight_schools", stan_schools, tmpdir)
rc = stan_sample(m_schools; data, save_warmup=true)

@assert success(rc)

include_warmup = m_schools.save_warmup ? true : false
idata = inferencedata(m_schools; include_internals=true, include_warmup)

println()
idata |> display

println()
idata.posterior |> display

println()
idata.posterior.theta |> display

println()
idata.posterior_predictive |> display

println()
idata.log_likelihood |> display

println()
idata.sample_stats |> display

println()
idata.sample_stats.lp |> display

if include_warmup
    println()
    idata.warmup_sample_stats |> display

    println()
    idata.warmup_sample_stats.lp |> display
end


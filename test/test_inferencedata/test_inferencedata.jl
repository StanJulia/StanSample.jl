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
tmpdir = joinpath(pwd(), "notebooks", "tmp")
m_schools = SampleModel("eight_schools", stan_schools, tmpdir)
rc = stan_sample(m_schools; data, save_warmup=true)

@assert success(rc)

stan_nts = read_samples(m_schools, :namedtuples; include_internals=true)
keys(stan_nts) |> display

# (:treedepth__, :theta_tilde, :energy__, :y_hat, :divergent__, :accept_stat__, 
#   :n_leapfrog__, :mu, :lp__, :stepsize__, :tau, :theta, :log_lik)


function select_nt_ranges(nt::NamedTuple, ranges=[1:1000, 1001:2000])
    dct = convert(Dict, nt)
    dct1 = Dict{Symbol, Any}()
    for key in keys(dct)
        dct1[key] = dct[key][ranges[1]]
    end
    nt1 = namedtuple(dct1)
    dct2 = Dict{Symbol, Any}()
    for key in keys(dct)
        dct2[key] = dct[key][ranges[2]]
    end
    nt2 = namedtuple(dct2)
    [nt1, nt2]
end


post_warmup, post = select_nt_ranges(stan_nts) # Use "default" ranges from SampleModel

#y_hat_warmup, y_hat = select_nt_ranges(NamedTupleTools.select(stan_nts, (:y_hat,)))
#log_lik_warmup, log_lik = select_nt_ranges(NamedTupleTools.select(stan_nts, (:log_lik,)))
#internals_warmup, internals_nts = select_nt_ranges(NamedTupleTools.select(stan_nts,
#    (:treedepth__, :energy__, :divergent__, :accept_stat__, :n_leapfrog__, :lp__, :stepsize__)))

idata = from_namedtuple(
    post; 
    posterior_predictive = (:y_hat,), 
    log_likelihood = (:log_lik,), 
    sample_stats = (:lp__, :treedepth__, :stepsize__, :n_leapfrog__, :energy__, :divergent__, :accept_stat__),
    #warmup_posterior = post_warmup
)

# What would be ideal, kind of pseudo code:

#=
idata = from_namedtuple(
    stan_nts; 
    posterior = (keys=(:mu, :theta, :theta_tilde, :tau), range=1001:2000),
    posterior_predictive = (keys=(:y_hat => :y,), range=1001:2000),
    log_likelihood = (keys=(:log_lik => :y,), range=1001:2000),
    sample_stats = (
        keys=(:lp__, :treedepth__, :stepsize__, :n_leapfrog__, :energy__, :divergent__, :accept_stat__),
        range=1001:2000),

    #warmup_posterior = (keys=(:mu, :theta, :theta_tilde, :tau), range=1:1000),
    # etc.
)
=#

# With a Dict based InferenceData object a similar result is possible with above `select_nt_ranges()` 
# and `NamedTupleTools.select()` calls.


println()
idata |> display
println()
idata.posterior |> display
println()
idata.posterior_predictive |> display
println()
idata.log_likelihood |> display
println()
idata.sample_stats |> display

from_namedtuple(stan_nts; posterior_predictive=:y_hat, log_likelihood=:log_lik)

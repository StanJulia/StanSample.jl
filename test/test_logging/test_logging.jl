using StanSample

mwe_model = "
parameters {
    real y;
}
model {
    y ~ normal(0.0, 1.0);
}
"

sm = SampleModel("mwe_model", mwe_model, joinpath(@__DIR__, "tmp"))

rc_mwe = stan_sample(sm; num_chains=5, use_cpp_chains=true, show_logging=true)

if success(rc_mwe)
    post = read_samples(sm, :dataframes)
end

display(available_chains(sm))

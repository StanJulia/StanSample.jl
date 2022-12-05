using StanSample

mwe_model = "
parameters {
    real y;
}
model {
    y ~ normal(0.0, 1.0);
}
"

sm = SampleModel("mwe_model", mwe_model)

rc_1 = stan_sample(sm; num_chains=5, use_cpp_chains=true, show_logging=true)

if success(rc_1)
    post = read_samples(sm, :dataframes)
end

display(available_chains(sm))

rc_2 = stan_sample(sm; num_chains=4, use_cpp_chains=true)

if success(rc_2)
    post = read_samples(sm, :dataframes)
end

display(available_chains(sm))

rc_3 = stan_sample(sm; num_chains=4, use_cpp_chains=false, show_logging=true)

if success(rc_3)
    post = read_samples(sm, :dataframes)
end

display(available_chains(sm))

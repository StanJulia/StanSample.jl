using StanSample

mwe_model = "
parameters {
    real y;
}
model {
    y ~ normal(0.0, 1.0);
}
"

sm= SampleModel("mwe_model", mwe_model, joinpath(@__DIR__, "tmp"))

rc_mwe = stan_sample(sm; num_cpp_chains=5, use_cpp_chains=true)

if success(rc_mwe)
    post_samps_mwe = read_samples(sm, :dataframes)
end

display(available_chains(sm))

@assert post_samps_mwe[1].y[1:5] == post_samps_mwe[1].y[1:5]
@assert post_samps_mwe[1].y[1:5] !== post_samps_mwe[2].y[1:5]

zip.(post_samps_mwe[1].y[1:5], post_samps_mwe[2].y[1:5]) |> display

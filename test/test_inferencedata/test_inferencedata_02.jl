using StanSample, DataFrames, InferenceObjects, Test

stan = "
parameters {
    matrix[2, 3] x;
}
model {
    for (i in 1:2)
        x[i,:] ~ std_normal();
}
";

sm = SampleModel("foo", stan);

rc = stan_sample(sm);

df = read_samples(sm, :dataframe)
df |> display
println()

df2 = read_samples(sm, :nesteddataframe)
df2 |> display
println()

idata = inferencedata(sm)
display(idata)

display(idata.posterior.x[15, 2, :, :])
display(df2.x[1015])

@test idata.posterior.x[15, 2, :, :] == df2.x[1015]

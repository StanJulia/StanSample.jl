using StanSample, DataFrames, JSON, InferenceObjects, Test

stan = "
parameters {
    real r;
    matrix[2, 3] x;
    tuple(real, real) bar;
    tuple(real, tuple(real, real)) bar2;
    tuple(real, tuple(real, tuple(real, real))) bar3;
}
model {
    r ~ std_normal();

    for (i in 1:2) {
        x[i,:] ~ std_normal();
    }

    bar.1 ~ std_normal();
    bar.2 ~ std_normal();
    bar2.1 ~ std_normal();
    bar2.2.1 ~ std_normal();
    bar2.2.2 ~ std_normal();
    bar3.1 ~ std_normal();
    bar3.2.1 ~ std_normal();
    bar3.2.2.1 ~ std_normal();
    bar3.2.2.2 ~ std_normal();
}
";

tmpdir = joinpath(@__DIR__, "tmp")
sm = SampleModel("tuple_model_2", stan, tmpdir)

rc = stan_sample(sm)

chns, col_names = read_samples(sm, :array; return_parameters=true)

display(col_names)
println()

display(size(chns))
println()

ex = StanSample.extract(chns, col_names; permute_dims=true)

println(size(ex[:bar]))
println()
println(ex[:bar][1:5])
println()
println(ex[:bar3][1:5])
println()
println(size(ex[:x]))
println()
display(ex[:x][1, 1, :, :])
println()

df = read_samples(sm, :dataframe)
df |> display

idata = inferencedata(sm)
display(idata)
println()

display(idata.posterior)
println()

display(idata.posterior.x)

df2 = read_samples(sm, :nesteddataframe)
#display(df2)

chns, col_names = read_samples(sm, :array; return_parameters=true)

display(col_names)
println()

display(size(chns))
println()

@test idata.posterior.bar3[1, 1, 1, :] == chns[1, 13:16, 1]


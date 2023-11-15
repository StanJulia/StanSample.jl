using StanSample, DataFrames, JSON, InferenceObjects, Test

stan = "
parameters {
    real r;
    matrix[2, 3] x;
    array[2, 2, 3] real<lower=0> z;
}
model {
    r ~ std_normal();

    for (i in 1:2) {
        x[i,:] ~ std_normal();
        for (j in 1:2)
            z[i, j, :] ~ std_normal();
    }
}
";

tmpdir = joinpath(@__DIR__, "tmp")
sm = SampleModel("tuple_model", stan, tmpdir)

rc = stan_sample(sm)

df2 = read_samples(sm, :nesteddataframe)
display(df2)

chns, col_names = read_samples(sm, :array; return_parameters=true)

display(col_names)
println()

display(size(chns))
println()

#ex = StanSample.extract(chns, col_names)

idata = inferencedata(sm)
display(idata)
println()

display(idata.posterior)
println()

@test reshape(Array(idata.posterior.z[1,1,1:2,1:2,3]), 4) == chns[1, 16:19, 1]

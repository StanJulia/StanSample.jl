using StanSample, DataFrames, JSON, InferenceObjects, NamedTupleTools

stan = "
parameters {
    real r;
    matrix[2, 2] x;
    tuple(real, real) bar;
}
model {
    r ~ std_normal();

    for (i in 1:2) {
        x[i,:] ~ std_normal();
    }

    bar.1 ~ std_normal();
    bar.2 ~ std_normal();
}
";

tmpdir = joinpath(@__DIR__, "tmp")
sm = SampleModel("tuple_model", stan, tmpdir)

rc = stan_sample(sm)

chns, names = read_samples(sm, :array; return_parameters=true)

display(names)
println()

display(size(chns))
println()

ex = StanSample.extract(chns, names; permute_dims=true)

println(ex[:bar][1:10])

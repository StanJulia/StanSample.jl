using StanSample, Test
pure = "
parameters {
    real r;
    real mu;
    real nu;
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

    mu ~ normal(0, 1);
    nu ~ normal(mu, 1);
}
generated quantities {
    complex z;
    complex_vector[2] zv;
    z = nu + nu * 2.0i;
    zv = to_complex([3 * nu, 5 * nu]', [nu * 4, nu * 6]');
    }
";

sm = SampleModel("pure_01", pure)
rc = stan_sample(sm)

df = read_samples(sm, :dataframe)

ndf = read_samples(sm, :nesteddataframe)

nnt = convert(NamedTuple, ndf)

lr = 1:size(df, 1)

@testset "Test arrays" begin

    for i in rand(lr, 5)
        @test ndf[i, :x] == reshape(Array(df[i, 4:9]), (2, 3))
        @test nnt.x[i] == reshape(Array(df[i, 4:9]), (2, 3))
    end
end

@testset "Complex values" begin

    for i in rand(lr, 5)
        @test ndf[i, :zv] == Array(df[i, ["zv.1", "zv.2"]])
        @test nnt.zv[i] == Array(df[i, ["zv.1", "zv.2"]])
    end
end

@testset "Tuples" begin

    for i in rand(lr, 5)
        @test ndf[i, :bar3] == (df[i, 15], (df[i, 16], (df[i, 17], df[i, 18])))
        @test nnt.bar3[i] == (df[i, 15], (df[i, 16], (df[i, 17], df[i, 18])))
    end
end

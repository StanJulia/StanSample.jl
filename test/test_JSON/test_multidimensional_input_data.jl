using StanSample, Statistics, Test

ProjDir = @__DIR__
n1 = 2
n2 = 3
n3 = 4
n4 = 4

stan0_2 = "
data { 
    int n1;
    int<lower=1> n2;
    array[n1, n2] real x;            
}

generated quantities {
    array[n1] real mu;
    for (i in 1:n1)
        mu[i] =  x[i, 1] + x[i, 2] +x[i, 3];
}
";

x = Array(reshape(1:n1*n2, n1, n2))
data = Dict("x" => x, "n1" => n1, "n2" => n2)
m0_2s = SampleModel("m0_2s", stan0_2)
rc0_2s = stan_sample(m0_2s; data)

if success(rc0_2s)
    post0_2s = read_samples(m0_2s, :dataframe)
    sums_stan_2 = Int.(mean(Array(post0_2s); dims=1))[1, :]
    sums_julia_2 = [sum(x[i, :]) for i in 1:n1]
    @test sums_stan_2 == sums_julia_2
end

stan0_3 = "
data { 
    int n1;
    int<lower=1> n2;
    int<lower=1> n3;
    array[n1, n2, n3] real x;            
}

generated quantities {
    array[n1, n2] real mu;
    for (i in 1:n1)
        for (j in 1:n2)
            mu[i, j] =  x[i, j, 1] + x[i, j, 2] +x[i, j, 3] + x[i, j, 4];
}
";

x = Array(reshape(1:n1*n2*n3, n1, n2, n3))
data = Dict("x" => x, "n1" => n1, "n2" => n2, "n3" => n3)

m0_3s = SampleModel("m0_3s", stan0_3)
rc0_3s = stan_sample(m0_3s; data)

if success(rc0_3s)
    post0_3s = read_samples(m0_3s, :dataframe)
    sums_stan_3 = Int.(mean(Array(post0_3s); dims=1))[1, :]
    sums_julia_3 = [sum(x[i, j, :]) for j in 1:n2 for i in 1:n1]
    @test sums_stan_3 == sums_julia_3
end

stan0_4 = "
data { 
    int n1;
    int<lower=1> n2;
    int<lower=1> n3;
    int<lower=1> n4;
    array[n1, n2, n3, n4] real x;            
}

generated quantities {
    array[n1, n2, n3] real mu;
    for (i in 1:n1)
        for (j in 1:n2)
            for (k in 1:n3)
                mu[i, j, k] =  x[i,j,k,1] + x[i,j,k,2] + x[i,j,k,3] + x[i,j,k,4];
}
";

x = Array(reshape(1:n1*n2*n3*n4, n1, n2, n3, n4))
data = Dict("x" => x, "n1" => n1, "n2" => n2, "n3" => n3, "n4" => n4)

m0_4s = SampleModel("m0_4s", stan0_4)
rc0_4s = stan_sample(m0_4s; data)

if success(rc0_4s)
    post0_4s = read_samples(m0_4s, :dataframe)
    sums_stan_4 = Int.(mean(Array(post0_4s); dims=1))[1, :]
    sums_julia_4 = [sum(x[i, j, k, :]) for k in 1:n3 for j in 1:n2 for i in 1:n1]
    @test sums_stan_4 == sums_julia_4
end

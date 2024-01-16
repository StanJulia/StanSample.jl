using StanSample

stan_data_2 = Dict("N" => 3, "nu" => 13, "L_Psi" => [1.0 0.0 0.0; 2.0 3.0 0.0; 4.0 5.0 6.0]);
stan_data = (N = 3, nu = 13, L_Psi = [1.0 0.0 0.0; 2.0 3.0 0.0; 4.0 5.0 6.0]);

model_code = "
data {
    int<lower=1> N;
    real<lower=N-1> nu;
    cholesky_factor_cov[N] L_Psi;
}
parameters {
    cholesky_factor_cov[N] L_X;
}
model {
    L_X ~ inv_wishart_cholesky(nu, L_Psi);
}
";

sm = SampleModel("test", model_code);
stan_sample(sm; data=stan_data_2);

ndf = read_samples(sm, :nesteddataframe)
println(ndf.L_X[1])
println("\n")

stan_sample(sm; data=stan_data_2);

ndf = read_samples(sm, :nesteddataframe)
println(ndf.L_X[1])
println("\n")

for i in 1:5
    stan_sample(sm; data=stan_data);
    ndf = read_samples(sm, :nesteddataframe)
    println(ndf.L_X[1])
    println("\n")
end

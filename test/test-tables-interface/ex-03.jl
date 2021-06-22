using StanSample, Test

df = CSV.read(joinpath(@__DIR__, "data", "WaffleDivorce.csv"), DataFrame);

stan5_1_t = "
data {
 int < lower = 1 > N; // Sample size
 vector[N] D; // Outcome
 vector[N] A; // Predictor
}

parameters {
 real a; // Intercept
 real bA; // Slope (regression coefficients)
 real < lower = 0 > sigma;    // Error SD
}

transformed parameters {
    vector[N] mu;
    mu = a + + bA * A;
}

model {
  a ~ normal( 0 , 0.2 );
  bA ~ normal( 0 , 0.5 );
  sigma ~ exponential( 1 );
  D ~ student_t( 2, mu , sigma );
}
generated quantities{
    vector[N] log_lik;
    for (i in 1:N)
        log_lik[i] = student_t_lpdf(D[i] | 2, mu[i], sigma);
}
";

begin
    data = (N=size(df, 1), D=df.Divorce, A=df.MedianAgeMarriage,
        M=df.Marriage)
    m5_1s_t = SampleModel("m5.1s_t", stan5_1_t)
    rc5_1s_t = stan_sample(m5_1s_t; data)

    if success(rc5_1s_t)
        post5_1s_t_df = read_samples(m5_1s_t; output_format=:dataframe)
    end
end

if success(rc5_1s_t)
    nt5_1s_t = read_samples(m5_1s_t)
    df5_1s_t = read_samples(m5_1s_t; output_format=:dataframe)
    log_lik_1_t = nt5_1s_t.log_lik'
    a5_1s_t, cnames = read_samples(m5_1s_t; output_format=:array, return_parameters=true);
end

st5_1_t = convert_a3d(a5_1s_t, cnames, Val(:table));
st5_1_t |> display

DataFrame(st5_1_t) |> display

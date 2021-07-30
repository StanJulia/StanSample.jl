using StanSample, CSV, AxisKeys, Test

df = CSV.read(joinpath(@__DIR__, "..", "..", "data", "chimpanzees.csv"), DataFrame);

# Define the Stan language model

stan10_4 = "
data{
    int N;
    int N_actors;
    int pulled_left[N];
    int prosoc_left[N];
    int condition[N];
    int actor[N];
}
parameters{
    vector[N_actors] a;
    real bp;
    real bpC;
}
model{
    vector[N] p;
    bpC ~ normal( 0 , 10 );
    bp ~ normal( 0 , 10 );
    a ~ normal( 0 , 10 );
    for ( i in 1:504 ) {
        p[i] = a[actor[i]] + (bp + bpC * condition[i]) * prosoc_left[i];
        p[i] = inv_logit(p[i]);
    }
    pulled_left ~ binomial( 1 , p );
}
";

data = (N = size(df, 1), N_actors = length(unique(df.actor)), 
    actor = df.actor, pulled_left = df.pulled_left,
    prosoc_left = df.prosoc_left, condition = df.condition);

# Sample using cmdstan

m10_4s = SampleModel("m10.4s", stan10_4)
rc10_4s = stan_sample(m10_4s; data);

# Result rethinking

rethinking = "
      mean   sd  5.5% 94.5% n_eff Rhat
bp    0.84 0.26  0.43  1.26  2271    1
bpC  -0.13 0.29 -0.59  0.34  2949    1

a[1] -0.74 0.27 -1.16 -0.31  3310    1
a[2] 10.88 5.20  4.57 20.73  1634    1
a[3] -1.05 0.28 -1.52 -0.59  4206    1
a[4] -1.05 0.28 -1.50 -0.60  4133    1
a[5] -0.75 0.27 -1.18 -0.32  4049    1
a[6]  0.22 0.27 -0.22  0.65  3877    1
a[7]  1.81 0.39  1.22  2.48  3807    1
";

# Update sections 

@testset "KeyedArray manipulations" begin
    if success(rc10_4s)
        ka = read_samples(m10_4s; output_format=:keyedarray)
        kb = ka(Symbol("a.1"))

        # Other manipulations
        
        @test Tables.istable(ka) == true
        # All draws of :a_1
        @test size(vcat(kb...)) == (4000,)
        # All of parameters @testset "Basic HelpModel" begin
        kar = reshape(ka.data, 4000, 9);
        @test size(kar) == (4000, 9)
        # Axes ranges
        @test axes(ka) == (Base.OneTo(1000), Base.OneTo(4), Base.OneTo(9))
        # Axes keys
        @test axiskeys(ka) == (
            1:1000, 1:4,
            [Symbol("a.1"), Symbol("a.2"), Symbol("a.3"), Symbol("a.4"), 
                Symbol("a.5"), Symbol("a.6"), Symbol("a.7"), :bp, :bpC]
        )
        # A single axis
        @test axiskeys(ka, :param) == vcat([Symbol("a.$i") for i in 1:7], :bp, :bpC)  

        # Test combining vector param 'a'
        ma = matrix(ka, "a");
        rma = reshape(ma.data, 4000, size(ma, 3))
        @test mean(rma, dims=1) ≈ [-0.7 10.9 -1 -1 -0.7 0.2 1.8] atol=0.7
    end
end
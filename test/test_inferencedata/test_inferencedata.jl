using CSV, DataFrames
using StanSample
using InferenceObjects
using PosteriorDB

# the posteriordb part, getting model code and data
posterior_name = "diamonds-diamonds"
pdb = database()
post = posterior(pdb, posterior_name)
model_data = Dict(string(k) => v for (k, v) in load_values(dataset(post)))
model_code = implementation(model(post), "stan")


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

data10_4 = (N = size(df, 1), N_actors = length(unique(df.actor)), 
    actor = df.actor, pulled_left = df.pulled_left,
    prosoc_left = df.prosoc_left, condition = df.condition);

# Sample using cmdstan

# the stan part
m10_4s = SampleModel("m10.4s", stan10_4)
rc10_4s = stan_sample(m10_4s; data=data10_4);

@assert success(rc10_4s)
stan_nts = read_samples(m10_4s, :namedtuples)

# the inferenceobjects part
idata = convert_to_inference_data(stan_nts)

idata |> display

idata.posterior |> display




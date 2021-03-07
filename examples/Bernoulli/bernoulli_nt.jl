######### StanSample Bernoulli example  ###########

using StanSample

ProjDir = @__DIR__

bernoulli_model = "
data {
  int<lower=1> N;
  int<lower=0,upper=1> y[N];
}
parameters {
  real<lower=0,upper=1> theta;
}
model {
  theta ~ beta(1,1);
  y ~ bernoulli(theta);
}
";

bernoulli_data = Dict("N" => 10, "y" => [0, 1, 0, 1, 0, 0, 0, 0, 0, 1])

# Keep tmpdir across multiple runs to prevent re-compilation
tmpdir = joinpath(@__DIR__, "tmp")

sm = SampleModel("bernoulli", bernoulli_model;
  method = StanSample.Sample(
    save_warmup=false,                           # Default
    thin=1,
    adapt = StanSample.Adapt(delta = 0.85)),
  tmpdir = tmpdir,
);

rc = stan_sample(sm; data=bernoulli_data);

if success(rc)
  nt = read_samples(sm)
  display(nt)
end

file_name = ProjDir * "/tmp/bernoulli_chain"
nt1, cnames1 = StanSample.read_csv(file_name, n_chains=4, n_samples=1000)

nt1 |> display

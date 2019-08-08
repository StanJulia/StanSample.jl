######### StanSample program example  ###########

using StanSample

ProjDir = dirname(@__FILE__)
cd(ProjDir)

bernoullimodel = "
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

tmpdir = ProjDir*"/tmp"

stanmodel = SampleModel("bernoulli", bernoullimodel, tmpdir=tmpdir);

println("\nTest printing of a stanmodel\n")
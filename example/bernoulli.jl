######### StanSample Bernoulli example  ###########

using StanSample, DataFrames

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

data = Dict("N" => 10, "y" => [0, 1, 0, 1, 0, 0, 0, 0, 0, 1])

# Keep tmpdir across multiple runs to prevent re-compilation
tmpdir = joinpath(ProjDir, "tmp")
isdir(tmpdir) &&  rm(tmpdir; recursive=true)

sm = SampleModel("bernoulli", bernoulli_model, tmpdir);

rc = stan_sample(sm; data);

if success(rc)
  st = read_samples(sm)
  display(DataFrame(st))
end

bernoulli_lib = joinpath(tmpdir, "bernoulli_model.so")
bernoulli_data = joinpath(tmpdir, "bernoulli_data_1.json")
blib = Libc.Libdl.dlopen(bernoulli_lib)

smb = StanModel(blib, bernoulli_data);
x = rand(smb.dims);
q = @. log(x / (1 - x));        # unconstrained scale

log_density_gradient!(smb, q, jacobian = 0)

println()
println("log_density and gradient of Bernoulli model:")
println((smb.log_density, smb.gradient))
println()

## free(smb)

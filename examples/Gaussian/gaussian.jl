######### StanSample Gaussian example  ###########

using StanSample, Distributions

gaussian_model = "
data {
  int<lower=0> N;
  vector[N] y;
}
parameters {
  real mu;
  real<lower=0> sigma;
}
model {
  mu ~ normal(0,1);
  sigma ~ cauchy(0,5);
  y ~ normal(mu,sigma);
}
"

simulateGaussian(; μ=0, σ=1, Nd, kwargs...) = (y=rand(Normal(μ, σ), Nd), N=Nd)

tmpdir = joinpath(@__DIR__, "tmp")
count = 0;
iter = 0

while iter < 100
  (y, N) = simulateGaussian(; Nd=5000)
  gaussian_data = Dict("N" => N, "y" => y)

  # Keep tmpdir across multiple runs to prevent re-compilation
  stanmodel = SampleModel("gaussian", gaussian_model; tmpdir=tmpdir)

  (sample_file, log_file) = stan_sample(stanmodel; data=gaussian_data)

  if !(sample_file == Nothing)
    global iter += 1
    # Convert to an MCMCChains.Chains object
    chns = read_samples(stanmodel)

    # Describe the MCMCChains using MCMCChains statistics
    cdf = describe(chns)

    # Show the same output in DataFrame format
    sdf = StanSample.read_summary(stanmodel)
    if sdf[:mu, :ess][1] >= 3999.0 || sdf[:sigma, :ess][1] >= 3999.0
      global count += 1
      println("$(iter), $(count) : mu_ess=$(sdf[:mu, :ess][1]), sigma_ess=$(sdf[:sigma, :ess][1])")
      display(cdf)
    end
  end
end
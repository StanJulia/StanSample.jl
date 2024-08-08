using StanSample, Test

ProjDir = @__DIR__
cd(ProjDir) # do

  bernoulli_model = "
    data { 
      int<lower=1> N; 
      array[N] int<lower=0,upper=1> y;
    } 
    parameters {
      real<lower=0,upper=1> theta;
    } 
    model {
      theta ~ beta(1,1);
      y ~ bernoulli(theta);
    }
  ";

  sm = SampleModel("bernoulli", bernoulli_model)
  observeddata = Dict("N" => 10, "y" => [0, 1, 0, 1, 0, 0, 0, 0, 0, 1])
  rc = stan_sample(
    sm;
    data=observeddata,
    num_samples=13,
    num_warmups=17,
    save_warmup=true,
    num_chains=1,
    sig_figs=2,
    stepsize=0.7,
  )

  @test success(rc)
  samples = read_samples(sm, :array)
  
  shape = size(samples)
  # number of samples, number of chains, number of parameters
  @test shape == (30, 1, 1)

  # read the log file
  f = open(sm.log_file[1], "r")
  # remove leading whitespace and chop off the "(default)" suffix
  config = [chopsuffix(lstrip(x), r"\s+\(default\)$"i) for x in eachline(f) if length(x) > 0]
  close(f)
  # check that the config is as expected

  required_entries = [
    "method = sample",
    "num_samples = 13",
    "num_warmup = 17",
    "save_warmup = true",
    "num_chains = 1",
    "sig_figs = 2",
    "stepsize = 0.7",
  ]

  for entry in required_entries
    @test entry in config
  end

using StanSample, Test

#StanBase.set_cmdstan_home!(homedir() * "/Projects/StanSupport/cmdstan_stanc3")

ProjDir = @__DIR__
cd(ProjDir) do

  bernoulli_model = "
    functions{
      #include model_specific_funcs.stan
      #include shared_funcs.stan // a comment  
      //#include shared_funcs.stan // a comment  
    }
    data { 
      int<lower=1> N; 
      int<lower=0,upper=1> y[N];
    } 
    parameters {
      real<lower=0,upper=1> theta;
    } 
    model {
      model_specific_function();
      theta ~ beta(my_function(),1);
      y ~ bernoulli(theta);
    }
  ";

  tmpdir = joinpath(ProjDir, "tmp")
  sm = SampleModel("bernoulli", bernoulli_model)

  observeddata = Dict("N" => 10, "y" => [0, 1, 0, 1, 0, 0, 0, 0, 0, 1])

  rc = stan_sample(sm, data=observeddata)

  if success(rc)
    # Convert to an MCMCChains.Chains object
    samples = read_samples(sm)

    for i in sm.n_chains[1]
      @test sum(samples[i].theta)/1000 ≈ 0.33 rtol=0.05
    end
  end

end
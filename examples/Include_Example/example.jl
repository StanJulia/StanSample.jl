using StanSample

ProjDir = @__DIR__
cd(ProjDir)

function full_model(base_model, functions)
  initial_model = open(f->read(f, String), base_model)
  funcs = open(f->read(f, String), functions)
  "functions{\n$(funcs)}\n"*initial_model
end

function full_model(base_model, shared_functions, local_functions)
  initial_model = open(f->read(f, String), base_model)
  shared_funcs = open(f->read(f, String), shared_functions)
  local_funcs = open(f->read(f, String), local_functions)
  "functions{\n$(shared_funcs)\n$(local_funcs)}\n"*initial_model
end

model = full_model("bernoulli.stan", "shared_funcs.stan")

stanmodel = SampleModel("bernoulli", model)

observeddata = Dict("N" => 10, "y" => [0, 1, 0, 1, 0, 0, 0, 0, 0, 1])

(sample_file, log_file) = stan_sample(stanmodel, data=observeddata)

if sample_file !== Nothing
  # Convert to an MCMCChains.Chains object
  chns = read_samples(stanmodel)

  # Describe the MCMCChains using MCMCChains statistics
  cdf = describe(chns)
  display(cdf)
end

println("\nOn to model2\n")

model2 = full_model("bernoulli2.stan", "shared_funcs.stan", "local_funcs.stan")

stanmodel = SampleModel("bernoulli2", model2,
  method=StanSample.Sample(save_warmup=true, 
    adapt = StanSample.Adapt(delta = 0.85)))

observeddata = Dict("N" => 10, "y" => [0, 1, 0, 1, 0, 0, 0, 0, 0, 1])

(sample_file, log_file) = stan_sample(stanmodel, data=observeddata)

if sample_file !== Nothing
  # Show the same output in DataFrame format
  sdf = read_summary(stanmodel)
  display(sdf)
  println()

  # Retrieve mean value of theta from the summary
  sdf[:theta, :mean]
end
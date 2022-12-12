using StanSample, BridgeStan

const BS = BridgeStan

BS.set_bridgestan_path!(StanSample.BRIDGESTAN_HOME)

p1=joinpath(StanSample.BRIDGESTAN_HOME, "test_models/bernoulli/bernoulli.stan")
p2=joinpath(StanSample.BRIDGESTAN_HOME, "test_models/bernoulli/bernoulli.data.json")

smb = BS.StanModel(stan_file = p1, data = p2);

println("This model's name is $(BS.name(smb)).")
println("It has $(BS.param_num(smb)) parameters.")

x = rand(BS.param_unc_num(smb));

q = @. log(x / (1 - x)); # unconstrained scale

lp, grad = BS.log_density_gradient(smb, q, jacobian = false)

println("log_density and gradient of Bernoulli model: $((lp, grad))")


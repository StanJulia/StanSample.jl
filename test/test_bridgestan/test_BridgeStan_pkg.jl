using StanSample, DataFrames

p1=joinpath(StanSample.BRIDGESTAN_HOME, "test_models/bernoulli/bernoulli.stan")
p2=joinpath(StanSample.BRIDGESTAN_HOME, "test_models/bernoulli/bernoulli.data.json")

smb = BS.StanModel(stan_file = p1, data = p2);

println("This model's name is $(BS.name(smb)).")
println("It has $(BS.param_num(smb)) parameters.")

x = rand(BS.param_unc_num(smb));

q = @. log(x / (1 - x)); # unconstrained scale

lp, grad = BS.log_density_gradient(smb, q, jacobian = false)

println("log_density and gradient of Bernoulli model: $((lp, grad))")

if typeof(smb) == BS.StanModel
    x = rand(BS.param_unc_num(smb))
    q = @. log(x / (1 - x))        # unconstrained scale

    lp, grad = BS.log_density_gradient(smb, q, jacobian = 0)

    println()
    println("log_density and gradient of Bernoulli model:")
    println((lp, grad))
    println()

    function sim(smb::BS.StanModel, x=LinRange(0.1, 0.9, 100))
        q = zeros(length(x))
        ld = zeros(length(x))
        g = Vector{Vector{Float64}}(undef, length(x))
        for (i, p) in enumerate(x)
            q[i] = @. log(p / (1 - p)) # unconstrained scale
            ld[i], g[i] = BS.log_density_gradient(smb, q[i:i],
                jacobian = 0)
        end
        return DataFrame(x=x, q=q, log_density=ld, gradient=g)
    end

  sim(smb) |> display
end

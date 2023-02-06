######### BridgeStan Bernoulli example  ###########

using BridgeStan, StanSample, DataFrames

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

tmpdir = joinpath(ProjDir, "tmp")
sm = SampleModel("bernoulli", bernoulli_model, tmpdir);
rc = stan_sample(sm; data);

if success(rc)
    post = read_samples(sm, :dataframe)
end

smb = create_smb(sm, joinpath(sm.tmpdir, "$(sm.name)_data_1.json"))

println("This model's name is $(BridgeStan.name(smb)).")
println("It has $(BridgeStan.param_num(smb)) parameters.")

if typeof(smb) == BridgeStan.StanModel
    x = rand(BridgeStan.param_unc_num(smb))
    q = @. log(x / (1 - x))        # unconstrained scale

    lp, grad = BridgeStan.log_density_gradient(smb, q, jacobian = 0)

    println()
    println("log_density and gradient of Bernoulli model:")
    println((lp, grad))
    println()

    function sim(smb::BridgeStan.StanModel, x=LinRange(0.1, 0.9, 100))
        q = zeros(length(x))
        ld = zeros(length(x))
        g = Vector{Vector{Float64}}(undef, length(x))
        for (i, p) in enumerate(x)
            q[i] = @. log(p / (1 - p)) # unconstrained scale
            ld[i], g[i] = BridgeStan.log_density_gradient(smb, q[i:i],
                jacobian = 0)
        end
        return DataFrame(x=x, q=q, log_density=ld, gradient=g)
    end

  sim(smb) |> display

end

using StanSample, Test

data_union = Union{Dict, NamedTuple, Vector, AbstractString}
init_union = Union{Dict, NamedTuple, Vector, AbstractString, StanSample.Init}

TestDir = @__DIR__
cd(TestDir)

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

tmpdir = joinpath(TestDir, "tmp")

function args(model::CmdStanSampleModel; 
  data::T=Dict(), init::S=Dict())  where {T <: data_union, S <: init_union}
  if !(data == Dict())
    println(data)
  else
    println("Input data not present.")
  end
  if !(init == Dict())
    println(init)
  else
    println("Input init not present.")
  end
  data
end

stanmodel = CmdStanSampleModel("bernoulli", bernoulli_model; tmpdir=tmpdir)

@test args(stanmodel, data=bernoulli_data) == bernoulli_data
println()
@test args(stanmodel, init=bernoulli_data) == Dict()
println()
@test args(stanmodel) == Dict()

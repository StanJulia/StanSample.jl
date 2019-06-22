using StanSample, Test

@testset "Bernoulli" begin
  include(joinpath(@__DIR__, "../examples/Bernoulli/bernoulli.jl"))
  s = summarize(chns)
  @test s[:theta, :mean][1] ≈ 0.34 atol=0.1
end


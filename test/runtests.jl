using StanSample, Test

TestDir = @__DIR__
tmpdir = mktempdir()
println()

basic_run_tests = [
  "test_basic_runs/test_bernoulli_dict.jl",
  "test_basic_runs/test_bernoulli_array_dict_1.jl",
  "test_basic_runs/test_bernoulli_array_dict_2.jl",
  "test_basic_runs/test_parse_interpolate.jl"
]

@testset "Bernoulli basic run tests" begin
  for test in basic_run_tests
    println("\nTesting: $test.")
    include(joinpath(TestDir, test))
    @test sdf[sdf.parameters .== :theta, :mean][1] ≈ 0.33 rtol=0.05
  end
  println()
end

sample_settings_tests = [
  "test_sample_settings/test_bernoulli.jl"
]

@testset "Bernoulli Sample() settings tests" begin
  for test in sample_settings_tests
    println("\nTesting: $test.")
    include(joinpath(TestDir, test))
    @test stanmodel.method.adapt.delta ≈ 0.85 atol=0.01
  end
  println()
end

generate_quantities_tests = [
  "test_generate_quantities/test_generate_quantities.jl"
]

@testset "Generate_quantities tests" begin
  for test in generate_quantities_tests
    println("\nTesting: $test.")
    include(joinpath(TestDir, test))
  end
  println()
end

using StanSample, Test

TestDir = @__DIR__
tmpdir = mktempdir()
println()

test_bernoulli = [
  "test_bernoulli/test_bernoulli_array_01.jl",
]

@testset "Bernoulli_01 array tests" begin
    include(joinpath(TestDir, "test_bernoulli/test_bernoulli_array_01.jl"))
    if success(rc)
      sdf = read_summary(sm)
      @test sdf[sdf.parameters .== :theta, :mean][1] ≈ 0.33 rtol=0.05

      (samples, parameters) = read_samples(sm; return_parameters=true)
      @test size(samples) == (1000, 1, 4)
      @test length(parameters) == 1

      (samples, parameters) = read_samples(sm;
        return_parameters=true, include_internals=true)
      @test size(samples) == (1000, 8, 4)
      @test length(parameters) == 8

      samples = read_samples(sm; include_internals=true)
      @test size(samples) == (1000, 8, 4)

      samples = read_samples(sm)
      @test size(samples) == (1000, 1, 4)
    end

    include(joinpath(TestDir, "test_bernoulli/test_bernoulli_array_02.jl"))
    if success(rc)
      sdf = read_summary(sm)
      @test sdf[sdf.parameters .== :theta, :mean][1] ≈ 0.33 rtol=0.05

      (samples, parameters) = read_samples(sm; return_parameters=true)
      @test size(samples) == (500, 1, 4)
      @test length(parameters) == 1

      samples = read_samples(sm; include_internals=true)
      @test size(samples) == (500, 8, 4)
    end
end

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


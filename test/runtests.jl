using StanSample, Test

import CompatHelperLocal as CHL
CHL.@check()

if haskey(ENV, "CMDSTAN") || haskey(ENV, "JULIA_CMDSTAN_HOME")

  TestDir = @__DIR__
  tmpdir = mktempdir()

  @testset "Bernoulli array tests" begin
    println("\nTesting test_bernoulli/test_bernoulli_keyedarray_01.jl")
    include(joinpath(TestDir, "test_bernoulli/test_bernoulli_keyedarray_01.jl"))

    if success(rc)
      sdf = read_summary(sm)
      sdf |> display

      @test sdf[sdf.parameters .== :theta, :mean][1] ≈ 0.33 rtol=0.05

      (samples, parameters) = read_samples(sm, :array; return_parameters=true)
      @test size(samples) == (1000, 1, 6)
      @test length(parameters) == 1

      (samples, parameters) = read_samples(sm, :array;
        return_parameters=true, include_internals=true)
      @test size(samples) == (1000, 8, 6)
      @test length(parameters) == 8

      samples = read_samples(sm, :array;
        include_internals=true)
      @test size(samples) == (1000, 8, 6)

      samples = read_samples(sm, :array)
      @test size(samples) == (1000, 1, 6)

    end

    println("\nTesting test_bernoulli/test_bernoulli_array_02.jl")
    include(joinpath(TestDir, "test_bernoulli/test_bernoulli_array_02.jl"))

    if success(rc)
      sdf = read_summary(sm)
      @test sdf[sdf.parameters .== :theta, :mean][1] ≈ 0.33 rtol=0.05

      (samples, parameters) = read_samples(sm, :array;
        return_parameters=true)
      @test size(samples) == (250, 1, 4)
      @test length(parameters) == 1

      samples = read_samples(sm, :array;
        include_internals=true)
      @test size(samples) == (250, 8, 4)

    end

  end

  println()
  test_inferencedata = [
    "test_inferencedata/test_inferencedata.jl",
    "test_inferencedata/test_inferencedata_02.jl",
  ]

  @testset "InferenceData interface" begin
    for test in test_inferencedata
      println("\nTesting: $test.")
      include(joinpath(TestDir, test))
    end
    println()
  end

  println()
  test_mcmcchains = [
    "test_mcmcchains/test_mcmcchains.jl",
  ]

  @testset "MCMCChains tests" begin
    for test in test_mcmcchains
      println("\nTesting: $test.")
      include(joinpath(TestDir, test))
    end
    println()
  end

  basic_run_tests = [
    "test_bernoulli/test_bernoulli_array_01.jl",
    "test_basic_runs/test_bernoulli_dict.jl",
    "test_basic_runs/test_bernoulli_array_dict_1.jl",
    "test_basic_runs/test_bernoulli_array_dict_2.jl",
    "test_basic_runs/test_parse_interpolate.jl"
  ]

  test_apinter = [
    "test_apinter/test_apinter.jl",
    "test_apinter/bernoulli_cpp.jl"
  ]

  @testset "Test correct chains are read in" begin
    for test in test_apinter
      println("\nTesting: $test.")
      include(joinpath(TestDir, test))
    end
    println()
  end
  
  test_logging = [
    "test_logging/test_logging.jl",
  ]

  @testset "Test logging" begin
    for test in test_logging
      println("\nTesting: $test.")
      include(joinpath(TestDir, test))
    end
    println()
  end
  
  @testset "Bernoulli sig-figs tests" begin
      println("\nTesting bernoulli.jl with sig_figs=18")
      include(joinpath(TestDir, "test_sig_figs", "bernoulli.jl"))
  end

  @testset "Bernoulli basic run tests" begin
    for test in basic_run_tests
      println("\nTesting: $test.")
      include(joinpath(TestDir, test))
      @test sdf[sdf.parameters .== :theta, :mean][1] ≈ 0.33 rtol=0.05
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
  
  test_tables_interface = [
    "test-tables-interface/ex-00.jl",
    "test-tables-interface/ex-01.jl",
    "test-tables-interface/ex-02.jl",
    "test-tables-interface/ex-03.jl",
    "test-tables-interface/ex-04.jl",
    "test-tables-interface/ex-05.jl"
  ]

  @testset "Tables.jl interface" begin
    for test in test_tables_interface
      println("\nTesting: $test.")
      include(joinpath(TestDir, test))
    end
    println()
  end

  test_dimensionaldata = [
    "test_dimensionaldata/test_dimensionaldata.jl",
  ]

  #=
  @testset "DimensionalData interface" begin
    for test in test_dimensionaldata
      println("\nTesting: $test.")
      include(joinpath(TestDir, test))
    end
    println()
  end
  =#
  
  test_keywords = [
    "test_keywords/test_bernoulli_keyedarray_01.jl",
    "test_keywords/test_bernoulli_keyedarray_02.jl",
    "test_keywords/test_bernoulli_keyedarray_03.jl",
  ]

  @testset "Seed and num_chains keywords" begin
    for test in test_keywords
      println("\nTesting: $test.")
      include(joinpath(TestDir, test))
    end
    println()
  end

  test_JSON = [
    "test_JSON/test_multidimensional_input_data.jl",
    "test_JSON/test_andy_pohl_model.jl"

    ]

  @testset "JSON" begin
    for test in test_JSON
      println("\nTesting: $test.")
      include(joinpath(TestDir, test))
    end
    println()
  end

  
else
  println("\nCMDSTAN and JULIA_CMDSTAN_HOME not set. Skipping tests")
end


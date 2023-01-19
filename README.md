# StanSample v7

| **Project Status**          |  **Build Status** |
|:---------------------------:|:-----------------:|
|![][project-status-img] | ![][CI-build] |

[docs-dev-img]: https://img.shields.io/badge/docs-dev-blue.svg
[docs-dev-url]: https://stanjulia.github.io/StanSample.jl/latest

[docs-stable-img]: https://img.shields.io/badge/docs-stable-blue.svg
[docs-stable-url]: https://stanjulia.github.io/StanSample.jl/stable

[CI-build]: https://github.com/stanjulia/StanSample.jl/workflows/CI/badge.svg?branch=master

[issues-url]: https://github.com/stanjulia/StanSample.jl/issues

[project-status-img]: https://img.shields.io/badge/lifecycle-active-green.svg

## Purpose

StanSample.jl wraps `cmdstan`'s `sample` method to generate draws from a Stan Language Program. It is the primary workhorse in the StanJulia ecosystem.

StanSample.jl v7 supports InferenceObjects.jl with `inferencedata(model)`. See note 1 below.

In StanSample v7 the earlier method of support for BridgeStan (< v1.0) has been dropped. See note 2 below.

## Notes

1. Use of both InferenceObjects.jl and the `read_samples()` output_format options :dimarray and :dimarrays (based on DimensionalData.jl) creates a conflict. Hence these output_format options are no longer included. See the example Pluto notebook `test_dimarray.jl`in Stan for an example how to still use that option. At some point in time InferenceObjects.jl might provide an alternative way to create a stacked DataFrame and/or DimensionalData object.

2. If `bridgestan` is cloned at the same level as 'cmdstan', StanSample will setup support for it. See `test_bridgestan.jl` for an example and INSTALLING_CMDSTAN.md. The example Pluto notebook `bridgestan.jl` in Stan.jl also demonstrates this.

## Prerequisites

You need a working installation of [Stan's cmdstan](https://mc-stan.org/users/interfaces/cmdstan.html), the path of which you should specify in either `CMDSTAN` or `JULIA_CMDSTAN_HOME`, e.g. in your `~/.julia/config/startup.jl` include a line like:

```Julia
# CmdStan setup
ENV["CMDSTAN"] =
     expanduser("~/.../cmdstan/") # replace with your path
```

Or you can define and export CMDSTAN in your .profile, .bashrc, .zshrc, etc.

For more details see [this file](https://github.com/StanJulia/StanSample.jl/blob/master/INSTALLING_CMDSTAN.md).

See the `example/bernoulli.jl` for a basic example. Many more examples and test scripts are available in this package and also in Stan.jl.

## Multi-threading and multi-chaining behavior.

From StanSample.jl v6 onwards 2 mechanisms for in paralel drawing samples for chains are supported, i.e. on C++ level (using threads) and on Julia level (by spawning a Julia process for each chain). 

The `use_cpp_chains` keyword argument in the call to `stan_sample()` determines if chains are executed on C++ level or on Julia level. By default, `use_cpp_chains = false`.

From cmdstan-2.28.0 onwards it is possible to use C++ threads to run multiple chains by setting `use_cpp_chains=true` in the call to `stan_sample()`:
```
rc = stan_sample(_your_model_; use_cpp_chains=true, [ data | init | ...])
```

To enable multithreading in `cmdstan` specify this before the build process of `cmdstan`, i.e. before running `make -j9 build`. I typically create a `path_to_my_cmdstan_directory/make/local` file containing `STAN_THREADS=true`. You can see an example in `.github/CI.yml` script.

By default in either case `num_chains=4`. See `??stan_sample` for all keyword arguments. Internally, `num_chains` will be copied to either `num_cpp_chains` or `num_julia_chains`.

Currently I do not suggest to use both C++ and Julia level chains. Based on the value of `use_cpp_chains` (true or false) the `stan_sample()` method will set either `num_cpp_chains=num_chains; num_julia_chains=1` or `num_julia_chains=num_chains;num_cpp_chain=1`.

This default behavior can be disabled by setting the postional `check_num_chains` argument in the call to `stan_sample()` to `false`.

Threads on C++ level can be used in multiple ways, e.g. to run separate chains and to speed up certain operations. By default StanSample.jl's SampleModel sets the C++ num_threads to 4.

See the (updated for cmdstan-2.29.0) RedCardsStudy example [graphs](https://github.com/StanJulia/Stan.jl/tree/master/Examples/RedCardsStudy/graphs) in Stan.jl and [here](https://discourse.mc-stan.org/t/stan-num-threads-and-num-threads/25780/5?u=rob_j_goedman) for more details, in particular with respect to just enabling threads and including TBB or not on Intel, and also some indications of the performance on an Apple's M1/ARM processor running native (not using Rosetta and without Intel's TBB). 

In some cases I have seen performance advantages using both Julia threads and C++ threads but too many combined threads certainly doesn't help. Note that if you only want 1000 draws (using 1000 warmup samples for tuning), multiple chains (C++ or Julia) do not help.

## Installation

This package is registered. It can be installed with:

```Julia
pkg> add StanSample.jl
```

## Usage

Use this package like this:

```Julia
using StanSample
```

See the docstrings (in particular `??StanSample`) for more help.

## Versions

### Version 7.0.1

1. Updated column types for sample_stats (NamedTuples and DataFrames)

### Version 7.0.0

1. InferenceObjects.jl support.
2. Conditional support for BridgeStan.
3. Reduced support for :dimarray and :dimarrays option in `read_samples()`.

### Version 6.13.8

1. Support for InferenceObjects v0.3.
2. Many `tmp` directories created during testing have been removed from the repo.
3. Support for BridgeStan v1.0 has been dropped.

### Version 6.13.7

1. Moved InferenceObjects behind Requires
2. Method `inferencedata()` is using `inferencedata3()` currently

### Version 6.13.6

1. Added inferencedata3()
2. Added option to enable logging in the terminal (thanks to @FelixNoessler)

### Version 6.13.0 - 6.13.5

1. Many more (minor and a bit more) updates to `inferencedata()`
2. Updates to BridgeStan (more to be expected soon)
3. Fix for chain numbering when using CPP threads (thanks to @apinter)
4. Switched to use cmdstan-2.32.0 for testing
5. Updates to Examples_Notebooks (in particular now using both `inferencedata()` and `inferencedata2()`)
6. Dropped support for read_samples(m, :dimarray) as this conflicted with InferenceData

### Version 6.12.0

1. Added experimental version of inferencedata(). See example in ./test/test_inferencedata.jl
2. Added InferenceObjects.jl as a dependency
3. Dropped MonteCarloMeasurements.jl as a dependency (still supported using Requires)
4. Dropped MCMCChains.jl as a dependency (still supported using Requires)
5. Dropped AxisKeys.jl as a dependency

### Version 6.11.5

1. Add sig_figs field to SampleModel (thanks to Andrew Radcliffe).

This change enables the user to control the number of significant digits which are preserved in the output. sig_figs=6 is the default cmdstan option, which is what StanSample has been defaulting to.

Typically, a user should prefer to generate outputs with sig_figs=18 so that the f64's are uniquely identified. It might be wise to make such a recommendation in the documentation, but I suppose that casual users would complain about the correspondingly increased .csv sizes (and subsequent read times).

### Version 6.11.4

1. Dropped conversion to Symbols in `read_csv_files()` if internals are requested (`include_internals=true`)
2. Added InferenceObjects as a dependency.

This is part of the work with Set Haxen to enable working with InferenceData objects in a future release (probably v6.12).

### Version 6.11.1

1. Fix bridge_path in SampleModel.

### Version 6.11.0

1. Support for BridgeStan as a dependency of StanSample.jl (Thanks to Seth Axen)

### Version 6.10.0

1. Support for the updated version of BridgeStan.

### Version 6.9.3

1. A much better test has been added for multidimensional input arrays thanks to Andy Pohl (`test/test_JSON`).

### Version 6.9.2

1. More general handling of Array input data to cmdstan if the Array has more than 2 dimensions.

### Version 6.9.2

1. Experimental support for [BridgeStan](https://gitlab.com/roualdes/bridgestan).

### Version 6.9.0-1

1. For chains read in as either a :dataframe or a :nesteddataframe the function matrix(...) has been replaced by array(...). Depending on the the eltype of the requested column, array will return a Vector, a Matrix or an Array with 3 dimensions.
2. The function describe() has been added which returns a df with results based on Stan's stansummary executable.
3. A new method has been added to DataFrames.getindex to extract cells in stansummary DataFrame, e.g. ss1_1[:a, :ess].

### Version 6.8.0 (nesteddataframe is experimental!)

1. Added :nesteddataframe option to read_samples(). Maybe useful if cmdstan returns vectors or matrices.
2. Extended the matrix() function to matrix(df, Symbol).

### Version 6.7.0

1. Drops support for creating R files.
2. Requires StanBase 4.7.0

### Version 6.4.0

1. Introduced `available_chains("your model")`
2. Updated Redcardsstudy results for cmdstan-2.29.0

### Version 6.3.0-1

1. Switch to cmdstan-2.29.0 testing.

### Version 6.2.1

1. Better handling of .csv chain retrieval in read_csv_files.

### Version 6.2.0

1. Revert back to by default use Julia level chains.

### Version 6.1.1-2

1. Documentation improvements.

### version 6.1.0

1. Modified (simplified?) use of `num_chains` to define either number of chains on C++ or Julia level based on `use_cpp_chains` keyword argument to `stan_sample()`.

### Version 6.0.0

1. Switch to C++ threads by default.
2. Use JSON3.jl for data.json and init.json as replacement for data.r and init.r files.
3. The function `read_generated_quantities()` has been dropped.
4. The function `stan_generate_quantites()` now returns a DataFrame.

### Version 5.4 - 5.6

1. Full usage of num_threads and num_cpp_threads

### Version 5.3.1 & 5.3.2

1. Drop the use of the STAN_NUM_THREADS environment variable in favor of the keyword num_threads in stan_sample(). Default value is 4.

### Version 5.3

1. Enable local multithreading. Local as cmdstan needs to be built with STAN_THREADS=true (see make/local examples).

### Version 5.2

1. Switch use CMDSTAN environment variable

### version 5.1

1. Testing with conda based install (Windows, but also other platforms)

### Versions 5.0

1. Docs updates.
2. Fix for DimensionalData v0.19.1 (@dim no longer exported)
3. Added DataFrame parameter blocking option.

### Version 5.0.0

1. Keyword based SampleModel and stan_sample().
2. Dropped dependency on StanBase.
3. Needs cmdstan 2.28.1 (for num_threads).
4. `tmpdir` now positional argument in SampleZModel.
5. Refactor src dir (add `common` subdir).
6. stan_sample() is now an alias for stan_run().

### Version 4.3.0

1. Added keywords seed and n_chains to stan_sample().
2. SampleModel no longer uses shared fields (prep work for v5).

### version 4.2.0

1. Minor updates
2. Added test for MCMCChains

### Version 4.1.0

1. The addition of :dimarray and :dimarrays output_format (see ?read_samples).
2. No longer re-exporting many previously exported packages.
3. The use of Requires.jl to enable most output_format options.
4. All example scripts have been moved to Stan.jl (because of item 3).

### Version 4.0.0 (**BREAKING RELEASE!**)

1. Make KeyedArray chains the read_samples() default output.
2. Drop the output_format kwarg, e.g.: `read_samples(model, :dataframe)`.
3. Default output format is KeyedArray chains, i.e.: `chns = read_samples(model)`.

### Version 3.1.0

1. Introduction of Tables.jl interface as an output_format option (`:table`).
2. Overloading Tables.matrix to group a variable in Stan's output file as a matrix.
3. Re-used code in read_csv_files() for generated_quantities.
4. The read_samples() method now consistently applies keyword arguments start and chains.
5. The table for each chain output_format is :tables.
6. 
### Version 3.0.1

1. Thanks to the help of John Wright (@jwright11) all StanJulia packages have been tested on Windows. Most functionality work, with one exception. Stansummary.exe fails on Windows if warmup samples have been saved.

### Version 3.0.0

1. By default read_samples(model) will return a NamedTuple with all chains appended.
2. `output_format=:namedtuples` will provide a NamedTuple with separate chains.

### Version 2.2.5

1. Thanks to @yiyuezhuo, a function `extract` has been added to simplify grouping variables into a NamedTuple.
2. read_sample() output_format argument has been extended with an option to request conversion to a NamedTuple.

### Version 2.2.4

1. Dropped the use of pmap in StanBase

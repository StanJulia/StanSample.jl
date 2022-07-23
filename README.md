# StanSample v7.0

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

Thus, you need a working installation of [Stan's cmdstan](https://mc-stan.org/users/interfaces/cmdstan.html), the path of which you should specify in either `CMDSTAN` or `JULIA_CMDSTAN_HOME`, e.g. in your `~/.julia/config/startup.jl` include a line like:

```Julia
# CmdStan setup
ENV["CMDSTAN"] =
     expanduser("~/.../cmdstan/") # replace with your path
```

Or you can define and export CMDSTAN in your .profile, .bashrc, .zshrc, etc.

For more details see [this file](https://github.com/StanJulia/StanSample.jl/blob/master/INSTALLING_CMDSTAN.md).

See the `example/bernoulli.jl` for a basic example. Many more examples and test scripts are available in this package and also in Stan.jl.

## Multi-threading and multi-chaining behavior.

StanSample.jl v6 supports 2 mechanisms for in paralel drawing samples for chains, i.e. on C++ level (using threads) and on Julia level (by spawning a Julia process for each chain). 

The `use_cpp_chains` keyword argument in the call to `stan_sample()` determines if chains are executed on C++ level or on Julia level. By default, `use_cpp_chains = false`.

From cmdstan-2.28.0 onwards it is possible to use C++ threads to run multiple chains by setting `use_cpp_chains=true` in the call to `stan_sample()`:
```
rc = stan_sample(_your_model_; use_cpp_chains=true, [ data | init | ...])
```

To enable multithreading in `cmdstan` specify this before the build process of `cmdstan`, i.e. before running `make -j9 build`. I typically create a `path_to_my_cmdstan_directory/make/local` file containing `STAN_THREADS=true`.
You can see an exaple in `.github/CI.yml` script.

By default in either case `num_chains=4`. See `??stan_sample` for all keyword arguments. Internally, `num_chains` will be copied to either `num_cpp_chains` or `num_julia_chains`.

Currently I do not suggest to use both C++ and Julia level chains. Based on the value of `use_cpp_chains` (true or false) the `stan_sample()` method will set either `num_cpp_chains=num_chains; num_julia_chains=1` or `num_julia_chains=num_chains;num_cpp_chain=1`.

This default behavior can be disabled by setting the postional `check_num_chains` argument in the call to `stan_sample()` to `false`.

Threads on C++ level can be used in multiple ways, e.g. to run separate chains and to speed up certain operations. By default StanSample.jl's SampleModel sets the C++ num_threads to 4.

See the (updated for cmdstan-2.29.0) RedCardsStudy example [graphs](https://github.com/StanJulia/Stan.jl/tree/master/Examples/RedCardsStudy/graphs) in Stan.jl and [here](https://discourse.mc-stan.org/t/stan-num-threads-and-num-threads/25780/5?u=rob_j_goedman) for more details, in particular with respect to just enabling threads and including TBB or not on Intel, and also some indications of the performance on an Apple's M1/ARM processor running native (not using Rosetta and without Intel's TBB). 

In some cases I have seen performance advantages using both Julia threads and C++ threads but too many combined threads certainly doesn't help. Note that if you only want 1000 draws (using 1000 warmup samples for tuning), multiple chains (C++ or Julia) do not help a lot.

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

### Version 6.9.0

1. For chains read in as either a :dataframe or a :nesteddataframe the function matrix(...) has been replaced by array(...). Depending on the the eltype of the requested column, array will return a Vector, a Mtrix or an Array with 3 dimensions.
2. The function describe() has been added which returns a df with results based on Stan's stansummary executable.
3. A new methos has been added to DataFrames.getindex to extract cells in stansummary DataFrame, e.g. ss1_1[:a, :ess].

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

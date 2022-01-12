# StanSample

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

## Installation

Note: StanSample.jl v5 is a breaking change from StanSample.jl v4.

The most important difference is that all modifications to running a default `cmdstan` script are specified as keyword arguments to stan_sample(), e.g. in StanSample.jl v4:
```Julia
sm = SampleModel("bernoulli", bernoulli_model;
  method = StanSample.Sample(adapt = StanSample.Adapt(delta = 0.85)),
  tmpdir = tmpdir,
);

rc = stan_sample(sm; data, n_chains=2, seed=12);
```

will in StanSample.jl v5 look like:
```Julia
sm = SampleModel("bernoulli", bernoulli_model, tmpdir)
rc = stan_sample(sm; data, num_chains=2, seed=12, delta=0.85)
```

Note also that n_chains is now called `num_chains` and is a simple `Int`. In v4 this used to be a `Vector{int}`.

See the `example/bernoulli.jl` for a basic example.

This package is registered. It can be installed with:

```Julia
pkg> add StanSample.jl
```

You need a working [Stan's cmdstan](https://mc-stan.org/users/interfaces/cmdstan.html) installation, the path of which you should specify in either `CMDSTAN` or `JULIA_CMDSTAN_HOME`, eg in your `~/.julia/config/startup.jl` have a line like:

```Julia
# CmdStan setup
ENV["CMDSTAN"] =
     expanduser("~/src/cmdstan-2.28.2/") # replace with your path
```

This package is modeled after Tamas Papp's [StanRun.jl](https://github.com/tpapp/StanRun.jl) package. 

Note: StanSample.jl v5.3+, supports multithreading in the `cmdstan` binary and requires cmdstan v2.28.2 and up. To activate multithreading in `cmdstan` this needs to be specified during the build process of `cmdstan`. 

Once multithreading on C++ level is included in `cmdstan`, set num_threads in the call to stan_sample, e.g.:
```
rc = stan_sample(sm; data, num_threads=4, num__cpp_chains=4)
```

The default value for num_threads is 1. This is for CI workflows testing only.

In general, to run 4 chains drawing about the same number of samples as warmup samples, I mostly use Julia threads by having the environment variable `JULIA_NUM_THREADS=4`. The actual number of Julia threads are visible in `versioninfo()`.

But if Stan provides additional support I use (or at least try):
```
rc = stan_sample(sm; data, num_threads=4, num_cpp_chains=4, num_chains=1)
```

See the redcardsstudy example in Stan.jl and [here](https://discourse.mc-stan.org/t/stan-num-threads-and-num-threads/25780/5?u=rob_j_goedman) for more details, in particular with respect to just enabling threads and including TBB or not on Intel, and also some indications of the performance on an Apple's M1/ARM processor running native (not using Rosetta and without TBB). 

Some performance tests/examples are also included in DiffEqBayesStan.jl.

In some cases I have seen performance advantages using both Julia threads and C++ threads but too many combined threads certainly doesn't help. Note that if you only want 1000 draws (using 1000 warmup samples for tuning), multiple chains (C++ or Julia) do not help a lot.

## Usage

Use this package like this:

```Julia
using StanSample
```

See the docstrings (in particular `??StanSample`) for more help.

## Versions

### Version 5.4.0

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

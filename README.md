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

You need a working [Stan's cmdstan](https://mc-stan.org/users/interfaces/cmdstan.html) installation, the path of which you should specify in `JULIA_CMDSTAN_HOME`, eg in your `~/.julia/config/startup.jl` have a line like:

```Julia
# CmdStan setup
ENV["JULIA_CMDSTAN_HOME"] =
     expanduser("~/src/cmdstan-2.28.1/") # replace with your path
```

This package is modeled after Tamas Papp's [StanRun.jl](https://github.com/tpapp/StanRun.jl) package. 

## Usage

It is recommended that you start your Julia process with multiple worker processes to take advantage of parallel sampling, e.g.:

```sh
julia -p auto
```

Otherwise, `stan_sample` will use a single process.

Use this package like this:

```Julia
using StanSample
```

See the docstrings (in particular `??StanSample`) for more help.

## Versions

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

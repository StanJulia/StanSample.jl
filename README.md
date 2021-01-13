# StanSample

![Lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)<!--
![Lifecycle](https://img.shields.io/badge/lifecycle-maturing-blue.svg)
![Lifecycle](https://img.shields.io/badge/lifecycle-stable-green.svg)
![Lifecycle](https://img.shields.io/badge/lifecycle-retired-orange.svg)
![Lifecycle](https://img.shields.io/badge/lifecycle-archived-red.svg)
![Lifecycle](https://img.shields.io/badge/lifecycle-dormant-blue.svg) -->
[![Build Status](https://travis-ci.com/StanJulia/StanSample.jl.svg?branch=master)](https://travis-ci.com/StanJulia/StanSample.jl)
[![codecov.io](http://codecov.io/github/StanJulia/StanSample.jl/coverage.svg?branch=master)](http://codecov.io/github/StanJulia/StanSample.jl?branch=master)

## Important note

## Installation

This package is registered. Install with

```julia
pkg> add StanSample.jl
```

StanSample.jl v3 is slightly breaking in that the default return of `read_samples` has been update to be a NamedTuple, i.e. `output_format=:namedtuple`, while it used to return a 3 dimensional Array.

You need a working [Stan's cmdstan](https://mc-stan.org/users/interfaces/cmdstan.html) installation, the path of which you should specify in `JULIA_CMDSTAN_HOME`, eg in your `~/.julia/config/startup.jl` have a line like
```julia
# CmdStan setup
ENV["JULIA_CMDSTAN_HOME"] = expanduser("~/src/cmdstan-2.19.1/") # replace with your path
```

This package is modeled after Tamas Papp's [StanRun.jl](https://github.com/tpapp/StanRun.jl) package. 

## Usage

It is recommended that you start your Julia process with multiple worker processes to take advantage of parallel sampling, eg

```sh
julia -p auto
```

Otherwise, `stan_sample` will use a single process.

Use this package like this:

```julia
using StanSample
```

See the docstrings (in particular `?StanSample`) for more help.

## Versions

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

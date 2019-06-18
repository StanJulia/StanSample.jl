# StanSample

![Lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)<!--
![Lifecycle](https://img.shields.io/badge/lifecycle-maturing-blue.svg)
![Lifecycle](https://img.shields.io/badge/lifecycle-stable-green.svg)
![Lifecycle](https://img.shields.io/badge/lifecycle-retired-orange.svg)
![Lifecycle](https://img.shields.io/badge/lifecycle-archived-red.svg)
![Lifecycle](https://img.shields.io/badge/lifecycle-dormant-blue.svg) -->
[![Build Status](https://travis-ci.org/StanJulia/StanSample.jl.svg?branch=master)](https://travis-ci.org/StanJulia/StanSample.jl)
[![codecov.io](http://codecov.io/github/StanJulia/StanSample.jl/coverage.svg?branch=master)](http://codecov.io/github/StanJulia/StanSample.jl?branch=master)

A collection of routines for running [CmdStan](https://mc-stan.org/users/interfaces/cmdstan.html).


## Important note

### This is not a package being tested for release. If succesful, it might be used in CmdStan.jl v6.

## Installation

This package is registered. Install with

```julia
pkg> add StanSample
```

You need a working [CmdStan](https://mc-stan.org/users/interfaces/cmdstan.html) installation, the path of which you should specify in `JULIA_CMDSTAN_HOME`, eg in your `~/.julia/config/startup.jl` have a line like
```julia
# CmdStan setup
ENV["JULIA_CMDSTAN_HOME"] = expanduser("~/src/cmdstan-2.19.1/") # replace with your path
```

This package is derived from Tamas Papp's [StanRun.jl]() package.

## Usage

It is recommended that you start your Julia process with multiple worker processes to take advantage of parallel sampling, eg

```sh
julia -p auto
```

Otherwise, `stan_sample` will use a single process.

Use this package like this:

```julia
using StanSample
model = StanModel("/path/to/model.stan") # directory should be writable, for compilation
data = (N = 100, x = randn(N, 1000))     # in a format supported by stan_dump
chains = stan_sample(model, data, 5)     # 5 chain paths and log files
```

See the docstrings (in particular `?StanSample`) for more.

# StanRun

![Lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)<!--
![Lifecycle](https://img.shields.io/badge/lifecycle-maturing-blue.svg)
![Lifecycle](https://img.shields.io/badge/lifecycle-stable-green.svg)
![Lifecycle](https://img.shields.io/badge/lifecycle-retired-orange.svg)
![Lifecycle](https://img.shields.io/badge/lifecycle-archived-red.svg)
![Lifecycle](https://img.shields.io/badge/lifecycle-dormant-blue.svg) -->
[![Build Status](https://travis-ci.org/tpapp/StanRun.jl.svg?branch=master)](https://travis-ci.org/tpapp/StanRun.jl)
[![codecov.io](http://codecov.io/github/tpapp/StanRun.jl/coverage.svg?branch=master)](http://codecov.io/github/tpapp/StanRun.jl?branch=master)

A collection of routines for running [CmdStan](https://mc-stan.org/users/interfaces/cmdstan.html).

## Installation

This package is registered. Install with

```julia
pkg> add StanRun
```

You need a working [CmdStan](https://mc-stan.org/users/interfaces/cmdstan.html) installation, the path of which you should specify in `JULIA_CMDSTAN_HOME`, eg in your `~/.julia/config/startup.jl` have a line like
```julia
# CmdStan setup
ENV["JULIA_CMDSTAN_HOME"] = expanduser("~/src/cmdstan-2.19.1/") # replace with your path
```

## Usage

It is recommended that you start your Julia process with multiple worker processes to take advantage of parallel sampling, eg

```sh
julia -p auto
```

Otherwise, `stan_sample` will use a single process.

Use this package like this:

```julia
using StanRun
model = StanModel("/path/to/model.stan") # directory should be writable, for compilation
data = (N = 100, x = randn(N, 1000))     # in a format supported by stan_dump
chains = stan_sample(model, data, 5)     # 5 chain paths and log files
```

See the docstrings (in particular `?StanRun`) for more.

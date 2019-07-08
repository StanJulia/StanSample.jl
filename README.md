# StanSample

![Lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)<!--
![Lifecycle](https://img.shields.io/badge/lifecycle-maturing-blue.svg)
![Lifecycle](https://img.shields.io/badge/lifecycle-stable-green.svg)
![Lifecycle](https://img.shields.io/badge/lifecycle-retired-orange.svg)
![Lifecycle](https://img.shields.io/badge/lifecycle-archived-red.svg)
![Lifecycle](https://img.shields.io/badge/lifecycle-dormant-blue.svg) -->
[![Build Status](https://travis-ci.org/StanJulia/StanSample.jl.svg?branch=master)](https://travis-ci.org/StanJulia/StanSample.jl)
[![codecov.io](http://codecov.io/github/StanJulia/StanSample.jl/coverage.svg?branch=master)](http://codecov.io/github/StanJulia/StanSample.jl?branch=master)

## Important note

### This is not a package being tested for release. If succesful, it might be used in CmdStan.jl v6 or as a support package underlying CmdStan.jl,

### Maybe this is an ok approach.

## Installation

This package is not registered. Install with

```julia
pkg> add https://github.com/StanJulia/StanSample.jl
```

You need a working [CmdStan](https://mc-stan.org/users/interfaces/cmdstan.html) installation, the path of which you should specify in `JULIA_CMDSTAN_HOME`, eg in your `~/.julia/config/startup.jl` have a line like
```julia
# CmdStan setup
ENV["JULIA_CMDSTAN_HOME"] = expanduser("~/src/cmdstan-2.19.1/") # replace with your path
```

This package is derived from Tamas Papp's [StanRun.jl](https://github.com/tpapp/StanRun.jl) package. It also uses StanDump.jl and StanSamples.jl. 

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

See the docstrings (in particular `?StanSample`) for more.

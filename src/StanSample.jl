"""

Helper infrastructure to compile and sample models using Stan's cmdstan binary.

$(SIGNATURES)

# Extended help

Exports:
```Julia
* `SampleModel`                        : Model structure to sample a Stan language model
* `StanModelError`                     : Exception error on cmdstan compilation failure
* `stan_sample`                        : Sample the model
* `read_samples`                       : Read the samples from .csv files
* `read_summary`                       : Read the cmdstan summary .csv file
* `stan_summary`                       : Create the stansummary .csv file
* `stan_generate_quantities`           : Simulate generated_quantities
* `read_generated_quantities`          : Read generated_quantities values
```
"""
module StanSample

using Requires
using Reexport

@reexport using AxisKeys

using CSV, DelimitedFiles, Unicode
using NamedTupleTools, Tables, TableOperations

using DocStringExtensions: FIELDS, SIGNATURES, TYPEDEF

import StanBase
import StanBase: get_cmdstan_home
import StanBase: get_n_chains, set_n_chains, stan_compile
import StanBase: executable_path, StanModelError, ensure_executable
import StanBase: CmdStanModels, RandomSeed, Init, Output
import StanBase: par, stan_dump
import StanBase: cmdline, read_summary, stan_summary
import StanBase: RandomSeed, Init, Output, StanModelError

function __init__()
  @require DataFrames="a93c6f00-e57d-5684-b7b6-d8193f3e46c0" include("utils/dataframes.jl")
  @require MonteCarloMeasurements="0987c9cc-fe09-11e8-30f0-b96dd679fdca" include("utils/particles.jl")
  @require DimensionalData="0703355e-b756-11e9-17c0-8b28908087d0" include("utils/dimarray.jl")
  @require MCMCChains="c7f686f2-ff18-58e9-bc7b-31028e88f75d" include("utils/mcmcchains.jl")
end

include("stanmodel/sample_types.jl")
include("stanmodel/SampleModel.jl")

include("stanrun/stan_sample.jl")
include("stanrun/cmdline.jl")
include("stanrun/diagnose.jl")
include("stanrun/stan_generated_quantities.jl")

include("stansamples/read_samples.jl")
include("stansamples/read_csv_files.jl")
include("stansamples/convert_a3d.jl")
include("stansamples/read_generated_quantities.jl")

include("utils/namedtuples.jl")
include("utils/tables.jl")
include("utils/keyedarray.jl")

export
  SampleModel,
  StanModelError,
  stan_sample,
  read_samples,
  read_summary,
  stan_summary,
  stan_generate_quantities,
  read_generated_quantities,
  convert_a3d,
  diagnose

end # module

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

using Reexport

@reexport using StanBase, DataFrames, MonteCarloMeasurements
@reexport using Tables, TableOperations, CSV

using Requires
using DocStringExtensions: FIELDS, SIGNATURES, TYPEDEF

import StanBase: stan_sample, get_cmdstan_home
import StanBase: cmdline, read_summary, stan_summary
import StanBase: RandomSeed, Init, Output, StanModelError

function __init__()
  @require MCMCChains="c7f686f2-ff18-58e9-bc7b-31028e88f75d" include("utils/mcmcchains.jl")
end

include("stanmodel/sample_types.jl")
include("stanmodel/SampleModel.jl")
include("stanrun/cmdline.jl")
include("stanrun/diagnose.jl")
include("stanrun/stan_generated_quantities.jl")
include("stansamples/read_samples.jl")
include("stansamples/read_csv_files.jl")
include("stansamples/convert_a3d.jl")
include("stansamples/read_generated_quantities.jl")
include("utils/dataframes.jl")
include("utils/namedtuples.jl")
include("utils/particles.jl")
include("utils/tables.jl")

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

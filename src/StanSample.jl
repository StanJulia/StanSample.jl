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

using CSV, DelimitedFiles, Unicode, Parameters
using NamedTupleTools, Tables, TableOperations
using StanDump, DataFrames

using DocStringExtensions: FIELDS, SIGNATURES, TYPEDEF

function __init__()
  @require MonteCarloMeasurements="0987c9cc-fe09-11e8-30f0-b96dd679fdca" include("utils/particles.jl")
  @require DimensionalData="0703355e-b756-11e9-17c0-8b28908087d0" include("utils/dimarray.jl")
  @require MCMCChains="c7f686f2-ff18-58e9-bc7b-31028e88f75d" include("utils/mcmcchains.jl")
  @require AxisKeys="94b1ba4f-4ee9-5380-92f1-94cde586c3c5" include("utils/keyedarray.jl")
end

include("stanmodel/common_definitions.jl")
include("stanmodel/SampleModel.jl")
include("stanmodel/update_model_file.jl")

include("stanrun/stan_sample.jl")
include("stanrun/cmdline.jl")
include("stanrun/diagnose.jl")
include("stanrun/stan_generated_quantities.jl")
include("stanrun/par.jl")

include("stansamples/read_samples.jl")
include("stansamples/read_csv_files.jl")
include("stansamples/convert_a3d.jl")
include("stansamples/read_generated_quantities.jl")
include("stansamples/read_summary.jl")
include("stansamples/stan_summary.jl")

include("utils/namedtuples.jl")
include("utils/tables.jl")
include("utils/dataframes.jl")

export
  SampleModel,
  stan_sample,
  read_samples,
  read_summary,
  stan_summary,
  stan_generate_quantities,
  read_generated_quantities,
  diagnose

end # module

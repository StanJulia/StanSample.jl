# read_samples

"""

Read sample output files created by StanSample.jl and return the requested `output_format`.
The default output_format is :array. Optionally the list of parameter symbols can be returned.

$(SIGNATURES)

# Extended help

### Required arguments
```julia
* `model`                     : SampleModel
```

### Optional arguments
```julia
* `start=1`                   : First sample number
* `output_format=:array`      : Requested format for samples
* `include_internals=false`   : Include internal Stan paramenters
* `return_parameters=false`   : Return a tuple of (output_format, parameter_symbols)
* `kwargs...`                 : Capture all other keyword arguments
```

Currently supported formats are:

1. :array (3d array format - [samples, parameters, chains])
2. :dataframe (DataFrames.DataFrame object, all chains appended)
3. :dataframes (Vector{DataFrames.DataFrame} object)
4. :particles (Dict{MonteCarloMeasurements.Particles})
5. :mcmcchains (MCMCChains.Chains object)
6. :mambachains (Mamba.Chains object)
7. :namedtuple (NamedTuple object)

The glue code for option 5 is enabled by Requires.jl if MCMCChains is loaded, option 6 requires
Mamba to be loaded.
"""
function read_samples(model::SampleModel;
  output_format=:array,
  include_internals=false,
  return_parameters=false,
  kwargs...)

  (res, names) = read_csv_files(model::SampleModel, output_format;
    include_internals=include_internals,
    kwargs...
  )

  if return_parameters
    return( (res, names) )
  else
    return(res)
  end

end

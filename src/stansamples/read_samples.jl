# read_samples

"""

Read sample output files created by StanSample.jl and return the requested `output_format`.
The default output_format is :namedtuple. Optionally the list of parameter symbols can be returned.

$(SIGNATURES)

# Extended help

### Required arguments
```julia
* `model`                     : SampleModel
```

### Optional arguments
```julia
* `start=1`                   : First sample number
* `output_format=:namedtuple` : Requested format for samples
* `include_internals=false`   : Include internal Stan paramenters
* `return_parameters=false`   : Return a tuple of (output_format, parameter_symbols)
* `kwargs...`                 : Capture all other keyword arguments
```

Currently supported formats are:

1. :array (3d array format - [samples, parameters, chains])
2. :namedtuple (DEFAULT: NamedTuple object, all chains appended)
3. :namedtuples (Vector{NamedTuple} object, individual chains)
4. :table (Tables object, individual chains)
5. :tables (Vector{Tables} object, individual chains chains)
6. :dataframe (DataFrames.DataFrame object, all chains appended)
7. :dataframes (Vector{DataFrames.DataFrame} object, individual chains)
8. :particles (Dict{MonteCarloMeasurements.Particles})
9. :mcmcchains (MCMCChains.Chains object)

The glue code for option 9 is enabled by Requires.jl if MCMCChains is loaded,.
"""
function read_samples(model::SampleModel;
  output_format=:namedtuple,
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

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
* `output_format=:namedtuple` : Requested format for samples
* `include_internals=false`   : Include internal Stan paramenters
* `return_parameters=false`   : Return a tuple of (output_format, parameter_symbols)
* `chains=1:m.n_chains[1]`    : Chains to be included in output
* `start=1`                   : First sample to be included
* `kwargs...`                 : Capture all other keyword arguments
```

Currently supported formats are:

1. :array (3d array format - [samples, parameters, chains])
2. :namedtuple (DEFAULT: NamedTuple object, all chains appended)
3. :namedtuples (Vector{NamedTuple} object, individual chains)
4. :table (Tables object, individual chains)
5. :tables (Vector{Tables} object, individual chains chains) # Not yet implemented
6. :dataframe (DataFrames.DataFrame object, all chains appended)
7. :dataframes (Vector{DataFrames.DataFrame} object, individual chains)
8. :particles (Dict{MonteCarloMeasurements.Particles})
9. :mcmcchains (MCMCChains.Chains object)

Basically chains can be returned as a NamedTuple, a StanTable, a DataFrame,
a Particles or an MCMCChains.Chains object.

For NamedTuple, StanTable and DataFrame all chains are appended or can be returned
a Vector{...} for each chain.

By default all chains will be read in. With the optional keyword argument `chains`
a subset of chains can be included, e.g. `chains = [2, 4]1.

The optional keyword argument `start` specifies is any initial (warm-up) samples
should be removed. 

Notes:
1. Use of the Stan `thinning` option will interfere with the value of start.
2. Start is the first sample included, e.g. with 1000 warm-up samples, start
should be set to 1001.

The NamedTuple output-format will extract and combine parameter vectors, e.g.
if Stan's cmdstan returns `a.1, a.2, a.3` the NamedTuple will just contain `a`.

For Tables object you can use the `select_block()` function to create an object
that conforms to the Tables interface:
```
stantable = read+samples(m10.4s; output_format=:table)
atable = select_block(stantable, "a")
```

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

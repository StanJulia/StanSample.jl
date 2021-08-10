# read_samples

"""

Read sample output files created by StanSample.jl and return the requested `output_format`.
The default output_format is :keyedarray. Optionally the list of parameter symbols can be returned.

$(SIGNATURES)

# Extended help

### Required arguments
```julia
* `model`                     : SampleModel
* `output_format=:keyedarray` : Requested format for samples
```

### Optional arguments
```julia
* `include_internals=false`   : Include internal Stan paramenters
* `return_parameters=false`   : Return a tuple of (output_format, parameter_symbols)
* `chains=1:m.n_chains[1]`    : Chains to be included in output
* `start=1`                   : First sample to be included
* `kwargs...`                 : Capture all other keyword arguments
```

Currently supported output_formats are:

1. :array (3d array format - [samples, parameters, chains])
2. :namedtuple (NamedTuple object, all chains appended)
3. :namedtuples (Vector{NamedTuple} object, individual chains)
4. :table (Tables object, all chains appended)
5. :tables (Vector{Tables} object, individual chains)
6. :dataframe (DataFrames.DataFrame object, all chains appended)
7. :dataframes (Vector{DataFrames.DataFrame} object, individual chains)
8. :particles (Dict{MonteCarloMeasurements.Particles})
9. :keyedarray (DEFAULT: KeyedArray object from AxisDict.jl)
10.:mcmcchains (MCMCChains.Chains object)

Basically chains can be returned as an Array, a KeyedArray, a NamedTuple, a StanTable,
a DataFrame, a Particles or an MCMCChains.Chains object.

For NamedTuple, StanTable and DataFrame all chains are appended or can be returned
as a Vector{...} for each chain.

By default all chains will be read in. With the optional keyword argument `chains`
a subset of chains can be included, e.g. `chains = [2, 4]`.

The optional keyword argument `start` specifies which initial (warm-up) samples
should be removed.

Notes:
1. Use of the Stan `thinning` option will interfere with the value of start.
2. Start is the first sample included, e.g. with 1000 warm-up samples, start
should be set to 1001.

The NamedTuple output-format will extract and combine parameter vectors, e.g.
if Stan's cmdstan returns `a.1, a.2, a.3` the NamedTuple will just contain `a`.

For KeyedArray and Table objects you can use the overloaded `matrix()` method to
extract a block of parametes:
```
stantable = read_samples(m10.4s; output_format=:table)
atable = matrix(stantable, "a")
```

The glue code for option 10 is enabled by Requires.jl if MCMCChains is loaded,.
"""
function read_samples(model::SampleModel, output_format=:keyedarray;
  include_internals=false,
  return_parameters=false,
  chains=1:model.n_chains[1],
  start=1,
  kwargs...)

  (res, names) = read_csv_files(model::SampleModel, output_format;
    include_internals=include_internals, start=start, chains=chains,
    kwargs...
  )

  if return_parameters
    return( (res, names) )
  else
    return(res)
  end

end

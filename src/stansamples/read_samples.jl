# read_samples

"""

Read sample output files created by StanSample.jl and return in the requested `output_format`.
The default output_format is :table. Optionally the list of parameter symbols can be returned.

$(SIGNATURES)

# Extended help

### Required arguments
```julia
* `model`                         : SampleModel
* `output_format=:table`          : Requested format for samples
```

### Optional arguments
```julia
* `include_internals=false`       : Include internal Stan paramenters
* `return_parameters=false`       : Return a tuple of (output_format, parameter_symbols)
* `chains=1:m.num_chains*m.num_cpp_chains` : Chains to be included in output (forked processes)
* `start=1`                       : First sample to be included
* `kwargs...`                     : Capture all other keyword arguments
```

Currently supported output_formats are:

1. :table (DEFAULT: StanTable Tables object, all chains appended)
2. :array (3d array format - [samples, parameters, chains])
3. :namedtuple (NamedTuple object, all chains appended)
4. :namedtuples (Vector{NamedTuple} object, individual chains)
5. :tables (Vector{Tables} object, individual chains)
6. :dataframe (DataFrames.DataFrame object, all chains appended)
7. :dataframes (Vector{DataFrames.DataFrame} object, individual chains)
8. :keyedarray (KeyedArray object from AxisDict.jl)
9. :particles (Dict{MonteCarloMeasurements.Particles})
10. :dimarray (Appended chains DimensionalData.DimArray object)
11. :dimarrays (DimensionalData.DimArray object)
12. :mcmcchains (MCMCChains.Chains object)
13. :nesteddataframe (DataFrame with vectors and matrices)

Basically chains can be returned as an Array, a KeyedArray, a DimArray, a NamedTuple,
a StanTable, a DataFrame (possibly with nested columns), a Particles or an MCMCChains.Chains object.

Options 8 to 12 are enabled by the presence of AxisKeys.jl, MonteCarloMeasurements.jl,
DimensionalData.jl or MCMCChains.jl.

For NamedTuple, StanTable, DimArray and DataFrame all chains are appended or can be returned
as a Vector{...} for each chain.

With the optional keyword argument `chains` a subset of chains can be included,
e.g. `chains = [2, 4]`.

The optional keyword argument `start` specifies which initial (warm-up) samples
should be removed.

Notes:
1. Use of the Stan `thinning` option will interfere with the value of start.
2. Start is the first sample included, e.g. with 1000 warm-up samples, start should be set to 1001.

The NamedTuple output-format will extract and combine parameter vectors, e.g.
if Stan's cmdstan returns `a.1, a.2, a.3` the NamedTuple will just contain `a`.

For KeyedArray and StanTable objects you can use the overloaded `matrix()` method to
extract a block of parametes:
```
stantable = read_samples(m10.4s, :table)
atable = matrix(stantable, "a")
```

For an appended DataFrame you can use e.g. `DataFrame(df, :log_lik)` to block a
set of variables, in this example the `log_lik.1, log_lik.2, etc.`.

Currently :table is the default chain output_format (a StanTable object).

In general it is safer to specify the desired output_format as this area
is still under heavy development in the Julia eco system. The default
has changed frequently!

"""
function read_samples(model::SampleModel, output_format=:table;
  include_internals=false,
  return_parameters=false,
  chains=1:model.num_chains,
  start=1,
  kwargs...)

  #println(chains)
  
  (res, names) = read_csv_files(model::SampleModel, output_format;
    include_internals, start, chains, kwargs...
  )

  if return_parameters
    return( (res, names) )
  else
    return(res)
  end

end

# convert_a3d

# Method that allows federation by setting the `output_format`  in the Stanmodel().

"""

Convert the output file created by cmdstan to the shape of choice

$(SIGNATURES)

# Extended help

### Method
```julia
convert_a3d(a3d_array, cnames; output_format=::Val{Symbol}, start=1)
```
### Required arguments
```julia
* `a3d_array::Array{Float64, 3},`      : Read in from output files created by cmdstan                                   
* `cnames::Vector{AbstractString}`     : Monitored variable names
```

### Optional arguments
```julia
* `::Val{Symbol}`                      : Output format, default is :mcmcchains
* `::start=1`                          : First draw for MCMCChains.Chains
```
Method called is based on the output_format defined in the stanmodel, e.g.:

   stanmodel = Stanmodel(`num_samples`=1200, thin=2, name="bernoulli", 
     model=bernoullimodel, `output_format`=:mcmcchains);

Current formats supported for conversion are:

1. :array (DEFAULT: a3d_array format)
2. :dataframe (DataFrames.DataFrame object, chains appended)
3. :dataframes (Vector{DataFrames.DataFrame} object)
4. :mcmcchains (MCMCChains.Chains object)
5. :particles (Dict{MonteCarloMeasurements.Particles})

The glue code for options 2 to 5 are enabled by Requires.jl if respectively
DataFrames, MCMCChains and MonteCarloMeasurements are loaded.
```

### Return values
```julia
* `res`                       : Draws converted to the specified format.
```
"""
convert_a3d(a3d_array, cnames, ::Val{:array}; kwargs...) = a3d_array

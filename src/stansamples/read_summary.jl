"""

Read summary output file created by stansummary. 

$(SIGNATURES)

# Extended help

### Required arguments
```julia
* `m`                                  : A Stan model object, e.g. SampleModel
```

### Optional positional arguments
```julia
* `printsummary=false`                 : Print cmdstan summary
```

### Returns
```julia
* `df`                                 : Dataframe containing the cmdstan summary
```

"""
function read_summary(m::SampleModel, printsummary=false)

  fname = "$(m.output_base)_summary.csv"
  !isfile(fname) && stan_summary(m, printsummary)

  df = CSV.read(fname, DataFrame; delim=",", comment="#")
  
  cnames = lowercase.(convert.(String, String.(names(df))))
  cnames[1] = "parameters"
  cnames[4] = "std"
  cnames[8] = "ess"
  rename!(df, Symbol.(cnames), makeunique=true)
  df[!, :parameters] = Symbol.(df[!, :parameters])
  
  df
  
end   # end of read_samples

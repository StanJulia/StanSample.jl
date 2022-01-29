# read_generated_quantities

"""

Read generated_quantities output files created by StanSample.jl.

$(SIGNATURES)

### Required arguments
```julia
* `model`                    : SampleModel
```
"""
function read_generated_quantities(model::SampleModel, 
    chains=[1];
    output_format=:table,
    kwargs...
  )

  #=
  read_csv_files(model::SampleModel, output_format;
    chains=chains,
    include_internals=false,
    start=1,
    kwargs...)
  =#
  available_chains[chains]

end   # end of read_generated_quantities


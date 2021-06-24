# read_generated_quantities

"""

Read generated_quantities output files created by StanSample.jl.

$(SIGNATURES)

### Required arguments
```julia
* `model`                    : SampleModel
```
"""
function read_generated_quantities(model::SampleModel, chains=[1];
    output_format=:namedtuple,
    kwargs...
  )

read_csv_files(model::SampleModel, output_format::Symbol;
  include_internals=false,
  chains=1:model.n_chains[1],
  start=1,
  kwargs...)

  read_csv_files(model::SampleModel, :namedtuple;
  include_internals=false,
  chains=[1],
  start=1,
  kwargs...)

end   # end of read_generated_quantities


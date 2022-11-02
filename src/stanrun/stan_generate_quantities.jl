using StanBase, CSV

"""
Create generated_quantities output files created by StanSample.jl.

$(SIGNATURES)

### Required arguments
```julia
* `model`                    : SampleModel
```

### Optional positional arguments
```julia
* `id=1`                     : Chain id, needs to be in 1:model.num_chains
* `chain="1"                 : CSV file suffix, e.g. ...chain_1_1.csv 
```

In chain suffix `...chain_i_j`:
```julia 
i : index in 1:num_julia_chains 
j : index in 1:num_cpp_chains 
```

The function checks the values of `id` and `chain`. If correct, a DataFrame
is returned. Each call will return a new set of values.

See also `?available_chains`.

"""
function stan_generate_quantities(
  m::SampleModel, id=1, chain="1";
  kwargs...)
  
  if id > m.num_chains
    @info "Please select an id in $(1:m.num_julia_chains)."
    return nothing
  end
  
  if !(chain in available_chains(m)[:suffix])
    @info "Chain $(chain) not in $(available_chains(m)[:suffix])"
    return nothing
  end

  local fname

  cmd = ``
  if isa(m, SampleModel)
    # Handle the model name field for unix and windows
    cmd = `$(m.exec_path)`

    # Sample() specific portion of the model
    cmd = `$cmd generate_quantities`
    
    # Fitted_params is required
    fname = "$(m.output_base)_chain_$chain.csv"
    cmd = `$cmd fitted_params=$fname`
    
    # Data file required?
    if length(m.data_file) > 0 && isfile(m.data_file[id])
      fname = m.data_file[id]
      cmd = `$cmd data file=$fname`
    end
    
    fname = "$(m.output_base)_generated_quantities_$chain.csv"
    cmd = `$cmd output file=$fname`
    cmd = `$cmd sig_figs=$(m.sig_figs)`
  end 
  
  cd(m.tmpdir) do
    run(pipeline(cmd, stdout="$(m.output_base)_generated_quantities_$id.log"))
  end
  
  CSV.read(fname, DataFrame; delim=",", comment="#")
  
end

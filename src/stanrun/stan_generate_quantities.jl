using StanBase, CSV

"""
Suffixes in csv file names created by StanSample.jl.

$(SIGNATURES)

### Required arguments
```julia
* `model`                    : SampleModel
```

Returns a vector with available chain suffixes.
"""
function available_chains(m::SampleModel)
  suffix_array = AbstractString[]
  for i in 1:m.num_julia_chains   # Number of exec processes
      for k in 1:m.num_cpp_chains   # Number of cpp chains handled in cmdstan

        if (m.use_cpp_chains && m.check_num_chains) || 
          !m.use_cpp_chains || m.num_cpp_chains == 1
          if m.use_cpp_chains && m.num_cpp_chains > 1
            csvfile_suffix = "$(k)"
          else
            #if m.use_cpp_chains && m.num_cpp_chains == 1
              csvfile_suffix = "$(i)"
            #else
            #  csvfile_suffix = "$(k)"
            #end
          end
        else
          if i == 1
            csvfile_suffix = "$(i)_$(k)"
          else
            csvfile_suffix = "$(i)_$(k + i - 1)"
          end
        end
        append!(suffix_array, [csvfile_suffix])
      end
  end
  Dict(:chain => collect(1:length(suffix_array)), :suffix => suffix_array)
end

export
  available_chains

"""
Create generated_quantities output files created by StanSample.jl.

$(SIGNATURES)

### Required arguments
```julia
* `model`                    : SampleModel
```

### Optional arguments
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
  end 
  
  cd(m.tmpdir) do
    run(pipeline(cmd, stdout="$(m.output_base)_generated_quantities_$id.log"))
  end
  
  CSV.read(fname, DataFrame; delim=",", comment="#")
  
end

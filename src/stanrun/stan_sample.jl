data_union = Union{Nothing, AbstractString, Dict, Array{T, 1} where T}
init_union = Union{Nothing, StanBase.Init, AbstractString, Dict, Array{T, 1} where T}

"""

Default `output_base` data files, in tmpdir.

$(SIGNATURES)

# Extended help

Internal, not exported.
"""
data_file_path(output_base::AbstractString, id::Int) = output_base * "_data_$(id).R"

"""

Default `output_base` init files, in tmpdir.

$(SIGNATURES)

# Extended help

Internal, not exported.
"""
init_file_path(output_base::AbstractString, id::Int) =
  output_base * "_init_$(id).R"

"""

Default `output_base` chain files, in tmpdir.

$(SIGNATURES)

# Extended help

Internal, not exported.
"""
sample_file_path(output_base::AbstractString, id::Int) =
  output_base * "_chain_$(id).csv"

"""

Default `output_base` for generated_quatities files, in tmpdir.

$(SIGNATURES)

# Extended help

Internal, not exported.
"""
generated_quantities_file_path(output_base::AbstractString, id::Int) = 
  output_base * "_generated_quantities_$(id).csv"

"""

Default `output_base` log files, in tmpdir.

$(SIGNATURES)

# Extended help

Internal, not exported.
"""
log_file_path(output_base::AbstractString, id::Int) =
  output_base * "_log_$(id).log"

"""

Default `output_base` diagnostic files, in tmpdir.

$(SIGNATURES)

# Extended help

Internal, not exported.
"""
diagnostic_file_path(output_base::AbstractString, id::Int) =
  output_base * "_diagnostic_$(id).csv"

"""

Execute the method contained in a CmdStanModel.

$(SIGNATURES)

# Extended help

### Required arguments
```julia
* `model <: CmdStanModels`             : CmdStanModel subtype, e.g. SampleModel
```

### Keyword arguments
```julia
* `init`                               : Init dict
* `data`                               : Data dict
* `n_chains=4`                         : Update number of chains.
* `seed=-1`                            : Set seed value (::Int)
```

### Returns
```julia
* `rc`                                 : Return code, 0 is success
```
"""
function stan_sample(model::T; kwargs...) where {T <: CmdStanModels}

    # How many chains?
    if :n_chains in keys(kwargs)
        model.n_chains = [kwargs[:n_chains]]
    end
    n_chains = get_n_chains(model)

    # Diagnostics files requested?
    diagnostics = false
    if :diagnostics in keys(kwargs)
        diagnostics = kwargs[:diagnostics]
        setup_diagnostics(model, n_chains)
    end

    if :seed in keys(kwargs)
        model.seed = RandomSeed(kwargs[:seed])
    end

    # Remove existing sample files
    for id in 1:n_chains
        sfile = sample_file_path(model.output_base, id)
        isfile(sfile) && rm(sfile)
    end

    :init in keys(kwargs) && update_R_files(model, kwargs[:init], n_chains, "init")
    :data in keys(kwargs) && update_R_files(model, kwargs[:data], n_chains, "data")

    model.cmds = [stan_cmds(model, id; kwargs...) for id in 1:n_chains]

    #println(typeof(model.cmds))
    #println()
    #println(model.cmds)

    run(pipeline(par(model.cmds), stdout=model.log_file[1]))
end

"""

Generate a cmdstan command line (a run `cmd`).

$(SIGNATURES)

Internal, not exported.
"""
function stan_cmds(model::T, id::Integer; kwargs...) where {T <: CmdStanModels}
    append!(model.sample_file, [sample_file_path(model.output_base, id)])
    append!(model.log_file, [log_file_path(model.output_base, id)])
    if length(model.diagnostic_file) > 0
      append!(model.diagnostic_file, [diagnostic_file_path(model.output_base, id)])
    end
    cmdline(model, id)
end

"""

Update data or init R files.

$(SIGNATURES)

# Extended help

### Required arguments
```julia
* `model`                         : CmdStanModels object
* `input`                         : Input data or init values
* `n_chains`                      : Number of chains in model
* `fname_part="data"`             : Data or init R files to be created
```

Not exported.
"""
function update_R_files(model, input, n_chains, fname_part="data")
  
  model_field = fname_part == "data" ? model.data_file : model.init_file
  if typeof(input) <: NamedTuple || typeof(input) <: Dict
    for i in 1:n_chains
      stan_dump(model.output_base*"_$(fname_part)_$i.R", input, force=true)
      append!(model_field, [model.output_base*"_$(fname_part)_$i.R"])
    end
  elseif  typeof(input) <: Array
    if length(input) == n_chains
      for (i, d) in enumerate(input)
        stan_dump(model.output_base*"_$(fname_part)_$i.R", d, force=true)
        append!(model_field, [model.output_base*"_$(fname_part)_$i.R"])
      end
    else
      @info "Data vector length does not match number of chains,"
      @info "only first element in data vector will be used,"
      for i in 1:n_chains
        stan_dump(model.output_base*"_$(fname_part)_$i.R", input[1], force=true)
        append!(model_field, [model.output_base*"_$(fname_part)_$i.R"])
      end
    end
  elseif typeof(input) <: AbstractString && length(input) > 0
    for i in 1:n_chains
      cp(input, "$(model.output_base)_$(fname_part)_$i.R", force=true)
      append!(model_field, [model.output_base*"_$(fname_part)_$i.R"])
    end
  else
    error("\nUnrecognized input argument: $(typeof(input))\n")
  end
  
end

"""
Helper function for the (deprecated) diagnostics file generation.

$(SIGNATURES)

# Extended help

I am not aware the diagnostic files contain other info then the regular .csv files.
Currently I have not disabled this functionality. Please let me know if this
feature should be included/enabled.
"""
function setup_diagnostics(model, n_chains)  
  for i in 1:n_chains
    append!(model.diagnostic_file, [model.output_base*"_diagnostic_$i.log"])
  end  
end

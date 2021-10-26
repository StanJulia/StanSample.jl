data_union = Union{Nothing, AbstractString, Dict, Array{T, 1} where T}
init_union = Union{Nothing, AbstractString, Dict, Array{T, 1} where T}

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
* `m <: CmdStanModels`             : CmdStanModel subtype, e.g. SampleModel
```

### Keyword arguments
```julia
* `init`                               : Init dict
* `data`                               : Data dict
* `num_chains=4`                       : Update number of chains.
* `seed=-1`                            : Set seed value (::Int)
```

### Returns
```julia
* `rc`                                 : Return code, 0 is success
```
"""
function stan_sample(m::T; kwargs...) where {T <: CmdStanModels}

    # How many chains and threads?
    if :num_chains in keys(kwargs)
        m.num_chains = kwargs[:num_chains]
    end
    if :num_threads in keys(kwargs)
        m.num_threads = kwargs[:num_thrads]
    end

    # Sample fields
    if :num_samples in keys(kwargs)
        m.num_samples = kwargs[:num_samples]
    end
    if :num_warmups in keys(kwargs)
        m.num_warmups = kwargs[:num_warmups]
    end
    if :save_warmups in keys(kwargs)
        m.save_warmups = kwargs[:save_warmups]
    end
    if :thin in keys(kwargs)
        m.thin = kwargs[:thin]
    end
    if :seed in keys(kwargs)
        m.seed = kwargs[:seed]
    end

    # Adapt fields
    if :engaged in keys(kwargs)
        m.engaged = kwargs[:engaged]
    end
    if :gamma in keys(kwargs)
        m.gamma = kwargs[:gamma]
    end
    if :delta in keys(kwargs)
        m.delta = kwargs[:delta]
    end
    if :kappa in keys(kwargs)
        m.kappa = kwargs[:kappa]
    end
    if :t0 in keys(kwargs)
        m.t0 = kwargs[:t0]
    end
    if :init_buffer in keys(kwargs)
        m.init_buffer = kwargs[:init_buffer]
    end
    if :term_buffer in keys(kwargs)
        m.term_buffer = kwargs[:term_buffer]
    end
    if :window in keys(kwargs)
        m.window = kwargs[:window]
    end

    #Algorithm fields
    if :algorithm in keys(kwargs)
        m.algorithm = kwargs[:algorithm]
    end
    if :engine in keys(kwargs)
        m.engine = kwargs[:engine]
    end
    if :max_depth in keys(kwargs)
        m.max_depth = kwargs[:max_depth]
    end
    if :int_time in keys(kwargs)
        m.int_time = kwargs[:int_time]
    end

    if :metric in keys(kwargs)
        m.metric = kwargs[:metric]
    end
    if :metric_file in keys(kwargs)
        m.metric_file = kwargs[:metric_file]
    end
    if :stepsize in keys(kwargs)
        m.stepsize = kwargs[:stepsize]
    end
    if :stepsize_jitter in keys(kwargs)
        m.stepsize_jitter = kwargs[:stepsize_jitter]
    end

    # Diagnostics files requested?
    diagnostics = false
    if :diagnostics in keys(kwargs)
        diagnostics = kwargs[:diagnostics]
        setup_diagnostics(m, m.num_chains)
    end

    # Remove existing sample files
    for id in 1:m.num_chains
        sfile = sample_file_path(m.output_base, id)
        isfile(sfile) && rm(sfile)
    end

    :init in keys(kwargs) && update_R_files(m, kwargs[:init],
        m.num_chains, "init")
    :data in keys(kwargs) && update_R_files(m, kwargs[:data],
        m.num_chains, "data")

    m.cmds = [stan_cmds(m, id; kwargs...) for id in 1:m.num_chains]

    #println(typeof(m.cmds))
    #println()
    #println(m.cmds)

    run(pipeline(par(m.cmds), stdout=m.log_file[1]))
end

"""

Generate a cmdstan command line (a run `cmd`).

$(SIGNATURES)

Internal, not exported.
"""
function stan_cmds(m::T, id::Integer; kwargs...) where {T <: CmdStanModels}
    append!(m.sample_file, [sample_file_path(m.output_base, id)])
    append!(m.log_file, [log_file_path(m.output_base, id)])
    if length(m.diagnostic_file) > 0
      append!(m.diagnostic_file, [diagnostic_file_path(m.output_base, id)])
    end
    cmdline(m, id)
end

"""

Update data or init R files.

$(SIGNATURES)

# Extended help

### Required arguments
```julia
* `m`                             : CmdStanModels object
* `input`                         : Input data or init values
* `num_chains`                    : Number of chains in model
* `fname_part="data"`             : Data or init R files to be created
```

Not exported.
"""
function update_R_files(m, input, num_chains, fname_part="data")
  
  m_field = fname_part == "data" ? m.data_file : m.init_file
  if typeof(input) <: NamedTuple || typeof(input) <: Dict
    for i in 1:num_chains
      stan_dump(m.output_base*"_$(fname_part)_$i.R", input, force=true)
      append!(m_field, [m.output_base*"_$(fname_part)_$i.R"])
    end
  elseif  typeof(input) <: Array
    if length(input) == num_chains
      for (i, d) in enumerate(input)
        stan_dump(m.output_base*"_$(fname_part)_$i.R", d, force=true)
        append!(m_field, [m.output_base*"_$(fname_part)_$i.R"])
      end
    else
      @info "Data vector length does not match number of chains,"
      @info "only first element in data vector will be used,"
      for i in 1:num_chains
        stan_dump(m.output_base*"_$(fname_part)_$i.R", input[1], force=true)
        append!(m_field, [m.output_base*"_$(fname_part)_$i.R"])
      end
    end
  elseif typeof(input) <: AbstractString && length(input) > 0
    for i in 1:num_chains
      cp(input, "$(m.output_base)_$(fname_part)_$i.R", force=true)
      append!(m_field, [m.output_base*"_$(fname_part)_$i.R"])
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
function setup_diagnostics(m, num_chains)  
  for i in 1:num_chains
    append!(m.diagnostic_file, [m.output_base*"_diagnostic_$i.log"])
  end  
end

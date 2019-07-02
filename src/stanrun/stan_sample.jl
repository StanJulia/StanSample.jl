data_union = Union{Dict, NamedTuple, Vector, AbstractString}
init_union = Union{Dict, NamedTuple, Vector, AbstractString, Init}

"""
$(SIGNATURES)

Default `output_base` data files, in the same directory as the model. Internal, not exported.
"""
data_file_path(output_base::AbstractString, id::Int) = output_base * "_data_$(id).R"

"""
$(SIGNATURES)

Default `output_base` init files, in the same directory as the model. Internal, not exported.
"""
init_file_path(output_base::AbstractString, id::Int) = output_base * "_init_$(id).R"

"""
$(SIGNATURES)

Sample `model.n_chains` from `model` using `data` and `init`.

Return the full paths of the sample files and logs as pairs.

In case of an error with a chain, the first value is `nothing`.

`output_base` is used to write the data file (using `StanDump.stan_dump`) and to determine
the resulting names for the sampler output. It defaults to the source file name without the
extension.

When `data` or `init` are provided as a `NamedTuple`or a `Dict`, it is written using
`StanDump.stan_dump` first. If an AbstractString is specified, it is used as a path
to an existing file which will be copied to the output directory unless the length == 0.

When `rm_samples` (default: `true`), remove potential pre-existing sample files after
compiling the model.
"""
function stan_sample(model::CmdStanSampleModel, init::S, data::T;
  rm_samples = true,
  diagnostics = false) where {S <: init_union, T <: data_union}
        
    update_R_files(model, init, model.n_chains, "init")
    update_R_files(model, data, model.n_chains, "data")
    diagnostics && setup_diagnostics(model, model.n_chains)
    
    _stan_sample(model;  rm_samples = rm_samples)
    
end

function stan_sample(model::CmdStanSampleModel, data::T;
  rm_samples = true, diagnostics = false) where {T <: data_union}
        
    update_R_files(model, data, model.n_chains, "data")
    diagnostics && setup_diagnostics(model, model.n_chains)
    
    _stan_sample(model;  rm_samples = rm_samples)
    
end


function stan_sample(model::CmdStanSampleModel;
  rm_samples = true, diagnostics = false)
    
    diagnostics && setup_diagnostics(model, model.n_chains)
    _stan_sample(model;  rm_samples = rm_samples)
    
end

function _stan_sample(model::CmdStanSampleModel;
                    rm_samples = true)
    rm_samples && rm.(StanRun.find_samples(model.sm))
    cmds_and_paths = [stan_cmd_and_paths(model, id)
                      for id in 1:model.n_chains]
    pmap(cmds_and_paths) do cmd_and_path
        cmd, (sample_path, log_path) = cmd_and_path
        success(cmd) ? sample_path : nothing, log_path
    end
end

"""
$(SIGNATURES)

Run a Stan command. Internal, not exported.
"""
function stan_cmd_and_paths(model::CmdStanSampleModel, id::Integer)
  
    append!(model.sample_file, [StanRun.sample_file_path(model.output_base, id)])
    model.output.file = model.sample_file[id]
    if length(model.diagnostic_file) > 0
      model.output.diagnostic_file = model.diagnostic_file[id]
    end
    append!(model.log_file, [StanRun.log_file_path(model.output_base, id)])
    append!(model.cmds, [cmdline(model, id)])
    pipeline(model.cmds[id]; stdout=model.log_file[id]), (model.sample_file[id], model.log_file[id])
    
end

function update_R_files(model, input, n_chains, fname_part="data")
  model_field = fname_part == "data" ? model.data_file : model.init_file
  if typeof(input) <: NamedTuple || typeof(input) <: Dict
    for i in 1:n_chains
      stan_dump(model.output_base*"_$(fname_part)_$i.R", input, force=true)
      append!(model_field, [model.output_base*"_$(fname_part)_$i.R"])
    end
  elseif  typeof(input) <: Vector{Dict{String, Any}}
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
    error("\nUnrecognized data or init specified\n")
  end
end

function setup_diagnostics(model, n_chains)
  for i in 1:n_chains
    append!(model.diagnostic_file, [model.output_base*"_diagnostic_$i.log"])
  end
end
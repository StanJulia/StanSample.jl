"""
$(SIGNATURES)

Default `output_base`, in the same directory as the model. Internal, not exported.
"""
data_file_path(output_base::AbstractString, id::Int) = output_base * "_data_$(id).R"

"""
$(SIGNATURES)

Sample `n_chains` from `model` using `data_file`. Return the full paths of the sample files
and logs as pairs. In case of an error with a chain, the first value is `nothing`.

`output_base` is used to write the data file (using `StanDump.stan_dump`) and to determine
the resulting names for the sampler output. It defaults to the source file name without the
extension.

When `data` is provided as a `NamedTuple`or a `Dict`, it is written using
`StanDump.stan_dump` first.

When `rm_samples` (default: `true`), remove potential pre-existing sample files after
compiling the model.
"""
function stan_sample(model::StanModel, data::T, n_chains::Integer;
                     output_base = default_output_base(model),
                      rm_samples = true) where {T<:NamedTuple}
    for i in 1:n_chains
      stan_dump(default_output_base(model)*"_data_$i.R", data, force=true)
    end
    _stan_sample(model, n_chains; 
      output_base = output_base, 
      rm_samples = rm_samples)
end

function stan_sample(model::StanModel,  data::T, n_chains::Integer;
                     output_base = default_output_base(model),
                     rm_samples = true) where {T<:Dict}
  for i in 1:n_chains
    stan_dump(default_output_base(model)*"_data_$i.R", data, force=true)
  end
  _stan_sample(model, n_chains; 
      output_base = output_base, 
      rm_samples = rm_samples)
end

function stan_sample(model::StanModel,  data::T, n_chains::Integer;
                     output_base = default_output_base(model),
                     rm_samples = true) where {T<:Vector}
    create_R_data_files(model, data, n_chains)
    _stan_sample(model, n_chains; 
      output_base = output_base, 
      rm_samples = rm_samples)
end

function _stan_sample(model::StanModel,
                    n_chains::Integer;
                    output_base = default_output_base(model),
                    rm_samples = true,)
    #println("Using StanSample version of stan_sample.\n")
    exec_path = StanRun.ensure_executable(model)
    rm_samples && rm.(StanRun.find_samples(model))
    cmds_and_paths = [stan_cmd_and_paths(exec_path, output_base, id, settings)
                      for id in 1:n_chains]
    pmap(cmds_and_paths) do cmd_and_path
        cmd, (sample_path, log_path) = cmd_and_path
        success(cmd) ? sample_path : nothing, log_path
    end
end


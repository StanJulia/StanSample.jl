"""
$(SIGNATURES)

Make a Stan command. Internal, not exported.
"""
function stan_cmd_and_paths(exec_path::AbstractString,
                            output_base::AbstractString, id::Integer,
                            settings::SamplerSettings)
    sample_file = StanRun.sample_file_path(output_base, id)
    log_file = StanRun.log_file_path(output_base, id)
    data_file = data_file_path(output_base, id)
    subcmd = create_subcmd(settings)
    cmd = `$(exec_path) $(subcmd) id=$(id) data file=$(data_file) output file=$(sample_file)`
    cmd = `$cmd refresh=$(settings.refresh[:refresh])`
    pipeline(cmd; stdout = log_file), (sample_file, log_file)
end

function create_subcmd(s::SamplerSettings)
  subcmd  = `sample`
  for section in [s.sample, s.adapt, s.random]
    if section == s.adapt
      subcmd = `$subcmd adapt `
    end
    if section == s.random
      subcmd = `$subcmd random `
    end
    for key in keys(section)
      subcmd = `$subcmd $(string(key))=$(section[key])`
    end
  end
  subcmd
end
  

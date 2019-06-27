"""
$(SIGNATURES)

Make a Stan command. Internal, not exported.
"""
function stan_cmd_and_paths(model::CmdStanSampleModel
                            output_base::AbstractString, id::Integer,
                            settings::SamplerSettings)
    sample_file = StanRun.sample_file_path(output_base, id)
    log_file = StanRun.log_file_path(output_base, id)
    data_file = data_file_path(output_base, id)
    cmd = create_cmd_line(model)
    #pipeline(cmd; stdout = log_file), (sample_file, log_file)
end

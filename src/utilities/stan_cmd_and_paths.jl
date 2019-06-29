"""
$(SIGNATURES)

Make a Stan command. Internal, not exported.
"""
function stan_cmd_and_paths(model::CmdStanSampleModel, id::Integer)
  
    append!(model.sample_file, [StanRun.sample_file_path(model.output_base, id)])
    model.output.file = model.sample_file[id]
    append!(model.log_file, [StanRun.log_file_path(model.output_base, id)])
    append!(model.cmds, [cmdline(model, id)])
    pipeline(model.cmds[id]; stdout=model.log_file[id]), (model.sample_file[id], model.log_file[id])
    
end

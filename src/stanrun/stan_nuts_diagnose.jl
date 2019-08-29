using CSV

function stan_nuts_diagnose(m::SampleModel; kwargs...)
  
  local fname
    
  cmd = ``
  if isa(m, SampleModel)
    # Handle the model name field for unix and windows
    cmd = `$(m.exec_path)`

    # Sample() specific portion of the model
    cmd = `$cmd generate_quantities`
    
    # Fitted_params is required
    fname = "$(m.output_base)_chain_$id.csv"
    cmd = `$cmd fitted_params=$fname`
    
    # Data file required?
    if length(m.data_file) > 0 && isfile(m.data_file[id])
      fname = m.data_file[id]
      cmd = `$cmd data file=$fname`
    end
    
    fname = "$(m.output_base)_generated_quantities_$id.csv"
    cmd = `$cmd output file=$fname`
  end 
  
  cd(m.tmpdir) do
    run(pipeline(cmd, stdout="$(m.output_base)_generated_quantities_$id.log"))
  end
  
  CSV.read(fname, delim=",", comment="#")
  
end

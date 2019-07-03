function par(cmd::Vector{String})
  res = `$(cmd[1])`
  for i in 2:length(cmd)
    res = res*` $(cmd[i])`
  end
  res
end


"""

# Method stan_summary

Display cmdstan summary 

### Method
```julia
stan_summary(
  model::StanModel,
  CmdStanDir=CMDSTAN_HOME
)
```
### Required arguments
```julia
* `model::Stanmodel             : Stanmodel
* `file::String`                : Name of file with samples
```

### Optional arguments
```julia
* CmdStanDir=CMDSTAN_HOME       : cmdstan directory for stansummary program
```

### Related help
```julia
?Stan.stan                      : Execute a StanModel
```
"""
function stan_summary(
  model::CmdStanSampleModel; 
  printsummary=false)
  
  local csvfile
  n_chains = model.n_chains
  
  samplefiles = String[]
  for i in 1:n_chains
    push!(samplefiles, "$(model.output_base)_chain_$(i).csv")
  end
  try
    pstring = joinpath("$(model.sm.cmdstan_home)", "bin", "stansummary")
    csvfile = "$(model.output_base)_summary.csv"
    isfile(csvfile) && rm(csvfile)
    cmd = `$(pstring) --csv_file=$(csvfile) $(par(samplefiles))`
    if printsummary
      resfile = open(cmd; read=true)
      print(read(resfile, String))
    else
      run(cmd)
    end
  catch e
    println(e)
  end
  return
end


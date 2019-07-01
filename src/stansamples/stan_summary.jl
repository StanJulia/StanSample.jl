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
  model::CmdStanSampleModel, n_chains=4; 
  printsummary=false)
  
  local res
  
  cd(model.tmpdir) do
    samplefiles = String[]
    for i in 1:n_chains
      push!(samplefiles, "$(model.name)_chain_$(i).csv")
    end
    try
      pstring = joinpath("$(model.sm.cmdstan_home)", "bin", "stansummary")
      csvfile = "$(model.name)_summary.csv"
      isfile(csvfile) && rm(csvfile)
      cmd = `$(pstring) --csv_file=$(csvfile) $(par(samplefiles))`
      resfile = open(cmd; read=true)
      printsummary && print(read(resfile, String))
    catch e
      println(e)
    end
  end
end


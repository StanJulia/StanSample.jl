"""

Create a `name`_summary.csv file. 

$(SIGNATURES)

# Extended help

### Required arguments
```julia
* `model::SampleModel             : SampleModel
```

### Optional arguments
```julia
* `printsummary=false             : Display summary
```

After completion a ..._summary.csv file has been created.
This file can be read as a DataFrame in by `df = read_summary(model)`

"""
function stan_summary(
  m::T, 
  printsummary=false) where {T <: CmdStanModels}
  
  #local csvfile
  n_chains = m.num_chains
  
  samplefiles = String[]
  for i in 1:n_chains
    push!(samplefiles, "$(m.output_base)_chain_$(i).csv")
  end
  try
    pstring = joinpath("$(m.cmdstan_home)", "bin", "stansummary")
    if Sys.iswindows()
      pstring = pstring * ".exe"
    end
    csvfile = "$(m.output_base)_summary.csv"
    isfile(csvfile) && rm(csvfile)
    cmd = `$(pstring) -c $(csvfile) $(par(samplefiles))`
    outb = IOBuffer()
    run(pipeline(cmd, stdout=outb));
    if printsummary
      cmd = `$(pstring) $(par(samplefiles))`
      resfile = open(cmd; read=true);
      print(read(resfile, String))
    end
  catch e
    println(e)
  end
  
  return
  
end


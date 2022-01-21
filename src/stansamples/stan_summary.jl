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
  n_chains = m.num_chains * m.num_cpp_chains
  
  samplefiles = String[]
  cpp_chains = model.num_cpp_chains
  julia_chains = model.num_chains

  # Read .csv files and return a3d[n_samples, parameters, n_chains]
  for i in 1:julia_chains   # Number of exec processes
    for k in 1:cpp_chains   # Number of cpp chains handled in cmdstan
      if m.num_cpp_chains == 1
        push!(samplefiles, "$(m.output_base)_chain_$(i).csv")
      else
        push!(samplefiles, "$(m.output_base)_chain_$(i)_$(k).csv")
      end
    end
  end
  println(samplefiles)
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


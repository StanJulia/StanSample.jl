"""

Create a `name`_summary.csv file. 

$(SIGNATURES)

# Extended help

### Required arguments
```julia
* `model::SampleModel             : SampleModel
```

### Optional positional arguments
```julia
* `printsummary=false             : Display summary
```

After completion a ..._summary.csv file has been created.
This file can be read as a DataFrame in by `df = read_summary(model))`

"""
function stan_summary(m::SampleModel, printsummary=false)
  
  samplefiles = String[]
  sufs = available_chains(m)[:suffix]
  for i in 1:length(sufs)
    push!(samplefiles, "$(m.output_base)_chain_$(sufs[i]).csv")
  end
  #println(samplefiles)

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


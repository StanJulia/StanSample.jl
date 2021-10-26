"""

Run Stan's diagnose binary on a model.

$(SIGNATURES)

### Required arguments
```julia
* `model`                    : SampleModel
```
"""
function diagnose(m::SampleModel)
  #local csvfile
  n_chains = m.num_chains
  
  samplefiles = String[]
  for i in 1:n_chains
    push!(samplefiles, "$(m.output_base)_chain_$(i).csv")
  end
  try
    pstring = joinpath("$(m.cmdstan_home)", "bin", "diagnose")
    if Sys.iswindows()
      pstring = pstring * ".exe"
    end
    cmd = `$(pstring) $(par(samplefiles))`
    resfile = open(cmd; read=true);
    print(read(resfile, String))
  catch e
    println(e)
  end
  
  return
end

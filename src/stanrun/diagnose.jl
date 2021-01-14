"""

Run Stan's diagnose binary on a model.

$(SIGNATURES)

### Required arguments
```julia
* `model`                    : SampleModel
```
"""
function diagnose(model::SampleModel)
  #local csvfile
  n_chains = model.n_chains[1]
  
  samplefiles = String[]
  for i in 1:n_chains
    push!(samplefiles, "$(model.output_base)_chain_$(i).csv")
  end
  try
    pstring = joinpath("$(model.cmdstan_home)", "bin", "diagnose")
    if Sys.iswindows()
      pstring = pstring * ".exe"
    end
    cmd = `$(pstring) $(StanBase.par(samplefiles))`
    resfile = open(cmd; read=true);
    print(read(resfile, String))
  catch e
    println(e)
  end
  
  return
end

export
    diagnose
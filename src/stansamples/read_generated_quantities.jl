# read_generated_quantities

"""

Read generated_quantities output files created by StanSample.jl.

$(SIGNATURES)

### Required arguments
```julia
* `model`                    : SampleModel
```
"""
function read_generated_quantities(model::SampleModel, chains=[1];
    output_format=:array,
    kwargs...
  )

  local a3d, monitors, index, idx, indvec, ftype, noofsamples
  
  # File path components of generated_quantities files
  # (missing the "_$(i).csv" part)
  output_base = model.output_base
  name_base ="_generated_quantities"

  # How many chains?
  n_chains = length(chains)

  # How many samples
  n_samples = model.method.num_samples
  
  # Read .csv files and return a3d[n_samples, parameters, n_chains]
  for i in chains
    if isfile(output_base*name_base*"_$(i).csv")
      instream = open(output_base*name_base*"_$(i).csv")
      
      # Skip initial set of commented lines, e.g. containing cmdstan version info, etc.      
      skipchars(isspace, instream, linecomment='#')
      
      # First non-comment line contains names of variables
      line = Unicode.normalize(readline(instream), newline2lf=true)
      idx = split(strip(line), ",")
      index = [idx[k] for k in 1:length(idx)]      
      indvec = 1:length(index)
      n_parameters = length(indvec)
      
      # Allocate a3d as we now know number of parameters
      if i == 1
        a3d = fill(0.0, n_samples, n_parameters, n_chains)
      end
      
      skipchars(isspace, instream, linecomment='#')
      for j in 1:n_samples
        skipchars(isspace, instream, linecomment='#')
        line = Unicode.normalize(readline(instream), newline2lf=true)
        if eof(instream) && length(line) < 2
          close(instream)
          break
        else
          flds = parse.(Float64, split(strip(line), ","))
          flds = reshape(flds[indvec], 1, length(indvec))
          a3d[j,:,i] = flds
        end
      end   # read in samples
    end   # read in next file if it exists
  end   # read in file for each chain
  
  cnames = convert.(String, idx[indvec])

  res = convert_a3d(a3d, cnames, Val(output_format); kwargs...)

  (res, Symbol.(cnames)) 

end   # end of read_generated_quantities


using Unicode, DelimitedFiles

"""

Read .csv output files created by Stan's cmdstan executable.

$(SIGNATURES)

# Extended help

### Required arguments
```julia
* `model`                              : SampleModel
* `output_format`                      : Requested output format
```

### Optional arguments
```julia
* `include_internals`                  : Include internal parameters
* `chains=1:model.n_chains[1]`         : Vector of chain id to include in output
* `start=1`                            : First sample to include in output
```
Not exported
"""
function read_csv_files(model::SampleModel, output_format::Symbol;
  include_internals=false,
  chains=1:model.n_chains[1],
  start=1,
  kwargs...)

  local a3d, monitors, index, idx, indvec, ftype, noofsamples
  
  # File path components of sample files (missing the "_$(i).csv" part)
  output_base = model.output_base
  name_base ="_chain"

  # How many samples?
  if model.method.save_warmup
    n_samples = floor(Int,
      (model.method.num_samples+model.method.num_warmup)/model.method.thin)
  else
    n_samples = floor(Int, model.method.num_samples/model.method.thin)
  end
  
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
        a3d = fill(0.0, n_samples, n_parameters, length(chains))
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
  
  # Filtering of draws before further processing
  
  cnames = convert.(String, idx[indvec])
  if include_internals
    snames = [Symbol(cnames[i]) for i in 1:length(cnames)]
    indices = 1:length(cnames)
  else
    pi = filter(p -> length(p) > 2 && p[end-1:end] == "__", cnames)
    snames = filter(p -> !(p in  pi), cnames)
    indices = Vector{Int}(indexin(snames, cnames))
  end 

  res = convert_a3d(a3d[start:end, indices, chains], snames, Val(output_format); kwargs...)

  (res, snames) 

end   # end of read_samples

using Unicode, DelimitedFiles

# read_samples

"""

Read sample output files created by StanSample.jl.

$(SIGNATURES)

### Required arguments
```julia
* `model`                    : SampleModel
```

### Optional arguments
```julia
* `start=1`                  : Sample nummering
```

"""
function read_samples(model::SampleModel; start=1)

  s1 = StanSamples.read_samples(model.output_base*"_chain_1.csv")
  sa = Vector{typeof(s1)}(undef, model.n_chains[1])
  sa[1] = s1
  if model.n_chains[1] > 1
    for i in 2:model.n_chains[1]
      sa[i] = StanSamples.read_samples(model.output_base*"_chain_$i.csv")
    end
  end

  sa

end   # end of read_samples

function read_samples(model::SampleModel, output_format::Symbol;  start=1)

  local a3d, monitors, index, idx, indvec, ftype, noofsamples
  
  output_base = model.output_base
  name_base ="_chain"
  n_samples = model.method.num_samples  
  n_chains = model.n_chains[1]
  
  # Handle save_warmup
  start = model.method.save_warmup ? model.method.num_warmup+1 : start
  
  # a3d will contain the samples such that a3d[s, i, c] where

  #   s: num_samples
  #   i: variables (from cmdstan .csv file)
  #   c: n_chains

  # Read .csv files created by each chain
  
  for i in 1:n_chains
    if isfile(output_base*name_base*"_$(i).csv")
      #noofsamples = 0
      instream = open(output_base*name_base*"_$(i).csv")
      #
      # Skip initial set of commented lines, e.g. containing cmdstan version info, etc.
      #
      skipchars(isspace, instream, linecomment='#')
      #
      # First non-comment line contains names of variables
      #
      line = Unicode.normalize(readline(instream), newline2lf=true)
      idx = split(strip(line), ",")
      index = [idx[k] for k in 1:length(idx)]      
      indvec = 1:length(index)
      
      if i == 1
        a3d = fill(0.0, n_samples, length(indvec), n_chains)
      end
      
      #println(size(a3d))
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
    end   # read in next file
  end   # read in file for each chain
  
  cnames = convert.(String, idx[indvec])
  chns = convert_a3d(a3d, cnames, Val(output_format); start=start)

end   # end of read_samples

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
* `chains=1:cpp_chains*julia_chains    : Which chains to include in output
* `start=1`                            : First sample to include in output
```
Not exported
"""
function read_csv_files(model::SampleModel, output_format::Symbol;
  include_internals=false,
  chains=1:model.num_chains,
  start=1,
  kwargs...)

  local a3d, monitors, index, idx, indvec, ftype, noofsamples
  
  # File path components of sample files (missing the "_$(i).csv" part)
  output_base = model.output_base
  name_base ="_chain"

  # How many samples?
  if model.save_warmup
    n_samples = floor(Int,
      (model.num_samples+model.num_warmups)/model.thin)
  else
    n_samples = floor(Int, model.num_samples/model.thin)
  end
  
  init_a3d = true
  cpp_chains = model.num_cpp_chains
  julia_chains = model.num_julia_chains
  total_number_of_chains = cpp_chains * julia_chains
  current_chain = 0
  #println([total_number_of_chains, current_chain])

  # Read .csv files and return a3d[n_samples, parameters, n_chains]
  for i in 1:julia_chains   # Number of exec processes
    for k in 1:cpp_chains   # Number of cpp chains handled in cmdstan

      if model.num_cpp_chains == 1 || model.num_julia_chains == 1
        csvfile = output_base*name_base*"_$(i).csv"
      else
        if i == 1
          csvfile = output_base*name_base*"_$(i)_$(k).csv"
        else
          csvfile = output_base*name_base*"_$(i)_$(k + i - 1).csv"
        end
      end
      #println("Reading "*csvfile)

      if isfile(csvfile)
        #println(csvfile*" found!")
        current_chain += 1
        instream = open(csvfile)
        
        # Skip initial set of commented lines, e.g. containing cmdstan version info, etc.      
        skipchars(isspace, instream, linecomment='#')
        
        # First non-comment line contains names of variables
        line = Unicode.normalize(readline(instream), newline2lf=true)
        idx = split(strip(line), ",")
        index = [idx[k] for k in 1:length(idx)]      
        indvec = 1:length(index)
        n_parameters = length(indvec)
        
        # Allocate a3d as we now know number of parameters
        if init_a3d
          init_a3d = false
          a3d = fill(0.0, n_samples, n_parameters, total_number_of_chains)
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
            a3d[j,:,current_chain] = flds
          end
        end   # read in samples
        #println("Filling $(current_chain) of $(size(a3d))")
      end   # read in next file if it exists
    end   # read in all cpp_chains
  end   # read in file all chains
  
  # Filtering of draws, parameters and chains before further processing
  
  cnames = convert.(String, idx[indvec])
  if include_internals
    snames = [Symbol(cnames[i]) for i in 1:length(cnames)]
    indices = 1:length(cnames)
  else
    pi = filter(p -> length(p) > 2 && p[end-1:end] == "__", cnames)
    snames = filter(p -> !(p in  pi), cnames)
    indices = Vector{Int}(indexin(snames, cnames))
  end 

  #println(size(a3d))
  res = convert_a3d(a3d[start:end, indices, chains], 
    snames, Val(output_format); kwargs...)

  (res, snames) 

end   # end of read_samples

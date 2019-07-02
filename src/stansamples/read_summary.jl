using DataFrames, Unicode, DelimitedFiles, MCMCChains

"""

# read_summary

Read summary output file created by stansummary. 

### Method
```julia
read_summary(model::CmdStanSampleModel)
```

### Required arguments
```julia
* `model::CmdStanSampleModel`    : CmdStanSampleModel object
```

"""
function read_summary(model::CmdStanSampleModel)
  
  df = DataFrame()
  
  cd(model.tmpdir) do
    file_path = "$(model.name)_summary.csv"

    if isfile(file_path)
      instream = open(file_path)
    else
      println(pwd())
      error("Summary file $(file_path) not found.")
    end

    skipchars(isspace, instream, linecomment='#')
    #
    # First non-comment line contains names of variables
    #
    line = Unicode.normalize(readline(instream), newline2lf=true)
    idx = split(strip(line), ",")
    index = [idx[k] for k in 1:length(idx)]
    indvec = 1:length(index)

    cnames = lowercase.(convert.(String, idx[indvec]))
    cnames[1] = "parameters"
    cnames[4] = "std"
    cnames[8] = "ess"

    rowno = 1; no_of_cols = 10
    mat = [[]]  
    for i in 1:no_of_cols-1
      append!(mat, [[]])
    end
    row = Vector{Any}(undef, no_of_cols)
    while !eof(instream)
      skipchars(isspace, instream, linecomment='#')
      line = Unicode.normalize(readline(instream), newline2lf=true)
      if eof(instream) && length(line) < 2
        close(instream)
        break
      else
        skipchars(isspace, instream, linecomment='#')
        line = split(line, ",")
        append!(mat[1], [Symbol(line[1][2:end-1])])
        for i in 2:no_of_cols
          append!(mat[i], [parse.(Float64, line[i])])
        end
      end
    end

    for (i, var) in enumerate(cnames)
      df[Symbol(var)] = mat[i]
    end
 end
  
  ChainDataFrame("CmdStan Summary", df)
  
end   # end of read_summary

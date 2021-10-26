"""

Update Stan language model file (if necessary).

$(SIGNATURES)

# Extended help

### Method
```julia
StanSample.update_model_file(
  file::String, 
  str::String
)
```
### Required arguments
```julia
* `file::AbstractString`                : File for Stan model
* `str::AbstractString`                 : Stan model string
```

Internal, not exported.
"""
function update_model_file(file::AbstractString, m::AbstractString)
  
  model1 = strip(parse_and_interpolate(m))
  model2 = ""
  if isfile(file)
    resfile = open(file, "r")
    model2 = strip(parse_and_interpolate(read(resfile, String)))
    model1 != model2 && rm(file)
  end
  if model1 != model2
    println("\n$(file) updated.")
    strmout = open(file, "w")
    write(strmout, model1)
    close(strmout)
  end
  
end

"""

Parse and interpolate Stan functionality into the Stan Language model before compilation
of the model by stanc.

$(SIGNATURES)

# Extended help

### Method
```julia
StanSample.parse_and_interpolate(
  model::AbstractString)
)
```
### Required arguments
```julia
* `model::AbstractString`              : String with Stan model
```

Internal, not exported.
"""
function parse_and_interpolate(m::AbstractString)
  newmodel = ""
  lines = split(m, "\n")
  for l in lines
    ls = String(strip(l))
    replace_strings = findall("#include", ls)
    if length(replace_strings) == 1 && 
        # handle the case the include line is commented out
        length(ls) > 2 && !(ls[1:2] == "//")
      for r in replace_strings
        ls = split(strip(ls[r[end]+1:end]), " ")[1]
        func = open(f -> read(f, String), strip(ls))
        newmodel *= "   "*func*"\n"
      end
    else
      if length(replace_strings) > 1
        error("Improper number of includes in line `$l`")
      else
        newmodel *= l*"\n"
      end
    end
  end
  newmodel
end

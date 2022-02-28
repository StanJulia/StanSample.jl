"""
Suffixes in csv file names created by StanSample.jl.

$(SIGNATURES)

### Required arguments
```julia
* `model`                    : SampleModel
```

Returns a vector with available chain suffixes.
"""
function available_chains(m::SampleModel)
  suffix_array = AbstractString[]
  for i in 1:m.num_julia_chains   # Number of exec processes
      for k in 1:m.num_cpp_chains   # Number of cpp chains handled in cmdstan

        if (m.use_cpp_chains && m.check_num_chains) || 
          !m.use_cpp_chains || m.num_cpp_chains == 1
          if m.use_cpp_chains && m.num_cpp_chains > 1
            csvfile_suffix = "$(k)"
          else
            #if m.use_cpp_chains && m.num_cpp_chains == 1
              csvfile_suffix = "$(i)"
            #else
            #  csvfile_suffix = "$(k)"
            #end
          end
        else
          if i == 1
            csvfile_suffix = "$(i)_$(k)"
          else
            csvfile_suffix = "$(i)_$(k + i - 1)"
          end
        end
        append!(suffix_array, [csvfile_suffix])
      end
  end
  Dict(:chain => collect(1:length(suffix_array)), :suffix => suffix_array)
end

export
  available_chains


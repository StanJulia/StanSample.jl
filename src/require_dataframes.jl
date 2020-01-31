using .DataFrames

"""

# convert_a3d

# Convert the output file(s) created by cmdstan to a DataFrame.

$(SIGNATURES)

"""
function convert_a3d(a3d_array, cnames, ::Val{:dataframe})
  # Inital DataFrame
  df = DataFrame(a3d_array[:, :, 1], Symbol.(cnames))

  # Append the other chains
  for j in 2:size(a3d_array, 3)
    df = vcat(df, DataFrame(a3d_array[:, :, j], Symbol.(cnames)))
  end
  df
end

"""

# convert_a3d

# Convert the output file(s) created by cmdstan to a Vector{DataFrame).

$(SIGNATURES)

"""
function convert_a3d(a3d_array, cnames, ::Val{:dataframes})

  dfa = Vector{DataFrame}(undef, size(a3d_array, 3))
  for j in 1:size(a3d_array, 3)
    dfa[j] = DataFrame(a3d_array[:, :, j], Symbol.(cnames))
  end

  dfa
end

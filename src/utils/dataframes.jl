using .DataFrames
import .DataFrames: DataFrame

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

"""

DataFrame()

# Block Stan named parameters, e.g. b.1, b.2, ... in a DataFrame.

$(SIGNATURES)

Example:

df_log_lik = DataFrame(m601s_df, :log_lik)
log_lik = Matrix(df_log_lik)

"""
function DataFrame(df::DataFrame, sym::Union{Symbol, String})
    n = string.(names(df))
    syms = string(sym)
    sel = String[]
    for (i, s) in enumerate(n)
        if length(s) > length(syms) && syms == n[i][1:length(syms)] &&
            n[i][length(syms)+1] in ['[', '.', '_']
            append!(sel, [n[i]])
        end
    end
    length(sel) == 0 && error("$syms not in $n")
    df[:, sel]
end

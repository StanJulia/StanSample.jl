function find_nested_columns(df::DataFrame)
    n = string.(names(df))
    nested_columns = String[]
    for (i, s) in enumerate(n)
        r = split(s, ".")
        if length(r) > 1
            append!(nested_columns, [r[1]])
        end
    end
    unique(nested_columns)
end

function select_nested_column(df::DataFrame, var::Union{Symbol, String})
    n = string.(names(df))
    sym = string(var)
    sel = String[]
    for (i, s) in enumerate(n)
        if length(s) > length(sym) && sym == n[i][1:length(sym)] && n[i][length(sym)+1] in ['.']
            append!(sel, [n[i]])
        end
    end
    length(sel) == 0 && @warn "$syms not in $n"
    #println(sel)
    df[:, sel]
end

"""

array(df, var)

Create a Vector, Matrix or Array from a column of a DataFrame 
(can be a nested DataFrame).

$(SIGNATURES)

### Required arguments
```julia
* `df::DataFrame` : DataFrame
* `var::::Union{Symbol, String}` : Column in the DataFrame
```

This is a generalization of the previously available `matrix()`
function.

Exported
"""
function array(df::DataFrame, var::Union{Symbol, String})
    if eltype(names(df)) == String
        varlocal = String(var)
        if !(varlocal in String.(names(df)))
            @warn "$(var) not found in df."
            return nothing
        end
    else
        varlocal = Symbol(var)
        if !(varlocal in Symbol.(names(df)))
            @warn "$(var) not found in df."
            return nothing
        end
    end 

    if eltype(df[:, varlocal]) <: Number
        m = Vector(df[:, var])
    elseif eltype(df[:, varlocal]) <: Vector
        m = zeros(nrow(df), length(df[1, varlocal]))
        i = 1 # rownumber
        for (i, r) in enumerate(eachrow(df[:, var]))
            m[i, :] = r[1]
        end
    elseif eltype(df[:, varlocal]) <: Matrix
        m = zeros(size(df[1, varlocal], 1), size(df[1, varlocal], 2), nrow(df))
        i = 1 # rownumber
        for (i, r) in enumerate(eachrow(df[:, var]))
            m[:, :, i] = r[1]
        end
    end
    m
end


function convert_a3d(a3d_array, cnames, ::Val{:nesteddataframe})

    # Inital DataFrame
    df = DataFrame(a3d_array[:, :, 1], Symbol.(cnames))

    # Append the other chains
    for j in 2:size(a3d_array, 3)
        df = vcat(df, DataFrame(a3d_array[:, :, j], Symbol.(cnames)))
    end

    nested_columns = find_nested_columns(df)
    #println(nested_columns)
    if length(nested_columns) == 0
        @info "No nested columns found."
        return df
    end
        
    dft = deepcopy(df)
    for colname in Symbol.(nested_columns)
        r = split(string(colname), ".")
        #println(r[1])
        col_df = select_nested_column(dft, Symbol(r[1]))
        col_names = names(col_df)
        #println(col_names)
        r = split(col_names[end] , ".")
        if length(r) >3
            @info "Array{T, N} where N > 3 not implemented in :nesteddataframe"
            return dft
        end
        #println(r)
        if length(r) == 2
            dft[!, colname] = [Vector(i) for i in eachrow(col_df)]
        elseif length(r) == 3
            dims = Meta.parse.(r[2:end])
            #println(dims)
            dft[!, colname] = [reshape(Vector(i), dims[1], dims[2]) for i in eachrow(col_df)]
        end
        for col in string.(col_names)
            dft = DataFrames.select(dft, Not(Symbol(col)))
        end
    end
    dft

end

export
    array
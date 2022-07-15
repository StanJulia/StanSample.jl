import DataFrames: describe
import DataFrames: getindex

function getindex(df::DataFrame, r::T, c) where {T<:Union{Symbol, String}}
    colstrings = String.(names(df))
    if !("parameters" in colstrings)
        @warn "DataFrame `df` does not have a column named `parameters`."
        return nothing
    end
    if eltype(df.parameters) <: Union{Vector{String}, Vector{Symbol}}
        @warn "DataFrame `df.parameters` is not of type `Union{String, Symbol}'."
        return nothing
    end
    rs = String(r)
    cs = String(c)
    if !(rs in String.(df.parameters))
        @warn "Parameter `$(r)` is not in $(df.parameters)."
        return nothing
    end
    if !(cs in colstrings)
        @warn "Statistic `$(c)` is not in $(colstrings)."
        return nothing
    end
    return df[df.parameters .== rs, cs][1]
end

"""

Create a StanSummary

$(SIGNATURES)

## Required positional arguments
```julia
* `model::SampleModel` # SampleModel used to create the draws
```

## Optional positional arguments
```julia
* `params` # Vector of Symbols or Strings to be included
```

## Keyword arguments
```julia
* `round_estimates = true` #
* `digits = 3` # Number of decimal digits
```

## Returns

A StanSummary object.


"""
function describe(model::SampleModel, params; 
    round_estimates=true, digits=3)

    if !(typeof(params) in [Vector{String}, Vector{Symbol}])
        @warn "Parameter vector is not a Vector of Strings or Symbols."
        return nothing
    end

    sdf = read_summary(model)
    sdf.parameters = String.(sdf.parameters)
    dfnew = DataFrame()
    for p in String.(params)
        append!(dfnew, sdf[sdf.parameters .== p, :])
    end

    if round_estimates
        colnames = names(dfnew)
        for col in colnames
            if !(col == "parameters")
                dfnew[!, col] = round.(dfnew[:, col]; digits=2)
            end
        end
    end

    dfnew
end

function describe(model::SampleModel; showall=false)
    sdf = read_summary(model)
    sdf.parameters = String.(sdf.parameters)
    if !showall
        sdf = sdf[8:end, :] 
    end
    sdf
end

export
    describe

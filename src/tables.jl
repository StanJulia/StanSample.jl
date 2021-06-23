struct StanTable{T <: AbstractMatrix} <: Tables.AbstractColumns
    names::Vector{Symbol}
    lookup::Dict{Symbol, Int}
    matrix::T
end

Tables.istable(::Type{<:StanTable}) = true

# getter methods to avoid getproperty clash
import Base: names
names(m::StanTable) = getfield(m, :names)
matrix(m::StanTable) = getfield(m, :matrix)
lookup(m::StanTable) = getfield(m, :lookup)
# schema is column names and types
Tables.schema(m::StanTable{T}) where {T} = Tables.Schema(names(m), fill(eltype(T),
    size(matrix(m), 2)))

# column interface
Tables.columnaccess(::Type{<:StanTable}) = true
Tables.columns(m::StanTable) = m
# required Tables.AbstractColumns object methods
Tables.getcolumn(m::StanTable, ::Type{T}, col::Int, nm::Symbol) where {T} = matrix(m)[:, col]
Tables.getcolumn(m::StanTable, nm::Symbol) = matrix(m)[:, lookup(m)[nm]]
Tables.getcolumn(m::StanTable, i::Int) = matrix(m)[:, i]
Tables.columnnames(m::StanTable) = names(m)

Tables.isrowtable(::Type{StanTable}) = true

function convert_a3d(a3d_array, cnames, ::Val{:table};
    chains=1:size(a3d_array, 3),
    start=1,
    return_internals=false,
    kwargs...)

    cnames = String.(cnames)

    if !return_internals
        pi = filter(p -> length(p) > 2 && p[end-1:end] == "__", cnames)
        p = filter(p -> !(p in  pi), cnames)
    else
        p = cnames
    end

    lookup_dict = Dict{Symbol, Int}()
    for (idx, name) in enumerate(p)
        lookup_dict[Symbol(name)] = idx
    end

    mats = [a3d_array[start:end, :, i] for i in chains]
    mat = vcat(mats...)
    StanTable(Symbol.(p), lookup_dict, mat)
end

import Tables: matrix
function matrix(st::StanTable, sym::Union{Symbol, String})
    n = string.(names(st))
    syms = string(sym)
    sel = String[]
    for (i, s) in enumerate(n)
        if length(s) > length(syms) && syms == n[i][1:length(syms)] &&
            n[i][length(syms)+1] in ['[', '.']
            append!(sel, [n[i]])
        end
    end
    length(sel) == 0 && error("$syms not in $n")
    tmp = st |> TableOperations.select(sel...) |> Tables.columntable
    Tables.matrix(tmp)
end

export
    StanTable,
    matrix

"""
# extract(chns::Array{Float64,3}, cnames::Vector{String})
RStan/PyStan style extract
chns: Array: [draws, vars, chains], cnames: ["lp__", "accept_stat__", "f.1", ...]
Output: namedtuple -> (var[1]=..., ...)
"""
function extract(chns::Array{Float64,3}, cnames::Vector{String}; permute_dims=false)
    draws, vars, chains = size(chns)

    ex_dict = Dict{Symbol, Array}()

    group_map = Dict{Symbol, Array}()
    for (i, cname) in enumerate(cnames)
        sp_arr = split(cname, ".")
        name = Symbol(sp_arr[1])
        if length(sp_arr) == 1
            ex_dict[name] = chns[:,i,:]
        else
            if !(name in keys(group_map))
                group_map[name] = Any[]
            end
            push!(group_map[name], (i, [Meta.parse(i) for i in sp_arr[2:end]]))
        end
    end

    for (name, group) in group_map
        max_idx = maximum(hcat([idx for (i, idx) in group]...), dims=2)[:,1]
        ex_dict[name] = similar(chns, max_idx..., draws, chains)
    end

    for (name, group) in group_map
        for (i, idx) in group
            ex_dict[name][idx..., :, :] = chns[:,i,:]
        end
    end

    if permute_dims
        for key in keys(ex_dict)
            if length(size(ex_dict[key])) > 2
                ex_dict[key] = permutedims(ex_dict[key], (2, 3, 1))
            end
        end
    end

    for name in keys(ex_dict)
        if name in [:treedepth__, :n_leapfrog__]
            ex_dict[name] = convert(Matrix{Int}, ex_dict[name])
        elseif name == :divergent__
            ex_dict[name] = convert(Matrix{Bool}, ex_dict[name])
        end
    end

    return (;ex_dict...)
end

function append_namedtuples(nts)
    dct = Dict()
    for par in keys(nts)
        if length(size(nts[par])) > 2
            r, s, c = size(nts[par])
            dct[par] = reshape(nts[par], r, s*c)
        else
            s, c = size(nts[par])
            dct[par] = reshape(nts[par], s*c)
        end
    end
    (;dct...)
end

import Base.convert

"""

# convert_a3d

# Convert the output file(s) created by cmdstan to a NamedTuple. Append all chains

$(SIGNATURES)

"""
function convert(T, df)
    dct = OrderedDict()
    for col_name in names(df)
        dct[Symbol(col_name)] = df[:, col_name]
    end
    nt = (;dct...)
end


"""

# convert_a3d

# Convert the output file(s) created by cmdstan to a NamedTuple. Append all chains

$(SIGNATURES)

"""
function convert_a3d(a3d_array, cnames, ::Val{:namedtuple})
    append_namedtuples(extract(a3d_array, cnames))
end

"""

# convert_a3d

# Convert the output file(s) created by cmdstan to a NamedTuple for each chain.

$(SIGNATURES)

"""
function convert_a3d(a3d_array, cnames, ::Val{:namedtuples})
    extract(a3d_array, cnames)
end

"""

# convert_a3d

# Convert the output file(s) created by cmdstan to a NamedTuple for each chain.

$(SIGNATURES)

"""
function convert_a3d(a3d_array, cnames, ::Val{:permuted_namedtuples})
    extract(a3d_array, cnames; permute_dims=true)
end

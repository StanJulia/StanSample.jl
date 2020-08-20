"""
# extract(chns::Array{Float64,3}, cnames::Vector{String})
RStan/PyStan style extract
chns: Array: [draws, vars, chains], cnames: ["lp__", "accept_stat__", "f.1", ...]
Output: namedtuple -> (var[1]=..., ...)
"""
function extract(chns::Array{Float64,3}, cnames::Vector{String})
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

    return (;ex_dict...)
end

"""

# convert_a3d

# Convert the output file(s) created by cmdstan to a NamedTuple.

$(SIGNATURES)

"""
function convert_a3d(a3d_array, cnames, ::Val{:namedtuple})
   extract(a3d_array, cnames)
end

"""
# extract(chns::Array{Float64,3}, cnames::Vector{String})

chns: Array: [draws, vars, chains]
cnames: ["lp__", "accept_stat__", "f.1", ...]

Output: namedtuple -> (var[1]=..., ...)
"""
function extract(chns::Array{Float64,3}, cnames::Vector{String}; permute_dims=false)
    draws, vars, chains = size(chns)

    ex_dict = Dict{Symbol, Array}()

    group_map = Dict{Symbol, Array}()
    
    for (i, cname) in enumerate(cnames)
        if isnothing(findfirst('.', cname)) && isnothing(findfirst(':', cname))
            ex_dict[Symbol(cname)] = chns[:,i,:]
        elseif !isnothing(findfirst('.', cname))
            sp_arr = split(cname, ".")
            name = Symbol(sp_arr[1])
            if !(name in keys(group_map))
                group_map[name] = Any[]
            end
            push!(group_map[name], (i, [Meta.parse(i) for i in sp_arr[2:end]]))
        elseif !isnothing(findfirst(':', cname))
            @info "Tuple output in Stan .csv files are flatened into a single row matrix."
            sp_arr = split(cname, ":")
            name = Symbol(sp_arr[1])
            if !(name in keys(group_map))
                group_map[name] = Any[]
            end
            push!(group_map[name], (i, [Meta.parse(i) for i in sp_arr[2:end]]))
        end
    end

    #println()
    #println(group_map)
    #println()

    for  (name, group) in group_map
        if !isnothing(findfirst('.', cnames[group[1][1]]))
            max_idx = maximum(hcat([idx for (i, idx) in group_map[name]]...), dims=2)[:,1]
            ex_dict[name] = similar(chns, max_idx..., draws, chains)
            for (j, idx) in group_map[name]
                ex_dict[name][idx..., :, :] = chns[:,j,:]
            end
        elseif !isnothing(findfirst(':', cnames[group[1][1]]))
            indx_arr = Int[]
            for (j, idx) in group_map[name]
                append!(indx_arr, j)
            end
            max_idx2 = [1, length(indx_arr)]
            ex_dict[name] = similar(chns, max_idx2..., draws, chains)
            #println(size(ex_dict[name]))
            cnt = 0
            for (j, idx) in group_map[name]
                cnt += 1
                #println([j, idx, cnt])
                ex_dict[name][1, cnt, :, :] = chns[:,j,:]
            end
        end
    end

    if permute_dims
        for key in keys(ex_dict)
            if length(size(ex_dict[key])) > 2
                tmp = 1:length(size(ex_dict[key]))
                perm = (tmp[end-1], tmp[end], tmp[1:end-2]...)
                ex_dict[key] = permutedims(ex_dict[key], perm)
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

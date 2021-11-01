using .DimensionalData
import .DimensionalData: @dim, XDim, YDim, ZDim

import StanSample: convert_a3d

@dim iteration XDim "iterations"
@dim chain YDim "chains"
@dim param ZDim "parameters"

function convert_a3d(a3d_array, cnames, ::Val{:dimarrays})
    psymbols= Symbol.(cnames)
    pa = permutedims(a3d_array, [1, 3, 2])

    DimArray(pa, (iteration, chain, param(psymbols)); name=:draws)
end

function convert_a3d(a3d_array, cnames, ::Val{:dimarray})
    psymbols= Symbol.(cnames)

    # Permute [draws, params, chains] to [draws, chains, params]
    a3dp = permutedims(a3d_array, [1, 3, 2])

    # Append all chains
    iters, chains, pars = size(a3dp)
    a3dpa = reshape(a3dp, iters*chains, pars)

    # Create the DimArray
    DimArray(a3dpa, (iteration, param(psymbols)); name=:draws)
end

function matrix(da::DimArray, sym::Union{Symbol, String})
    n = string.(dims(da, :param).val)
    syms = string(sym)
    sel = String[]
    for (i, s) in enumerate(n)
        if length(s) > length(syms) && syms == n[i][1:length(syms)] &&
            n[i][length(syms)+1] in ['[', '.', '_']
            append!(sel, [n[i]])
        end
    end
    length(sel) == 0 && error("$syms not in $n")
    da[param=At(Symbol.(sel))]
end

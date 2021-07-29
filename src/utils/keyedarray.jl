"""

# convert_a3d

# Convert the output file(s) created by cmdstan to a KeyedArray.

$(SIGNATURES)

"""
function convert_a3d(a3d_array, cnames, ::Val{:keyedarray})
    psymbols= Symbol.(cnames)
    pa = permutedims(a3d_array, [1, 3, 2])
    wrapdims(pa, 
        iteration=1:size(pa, 2), 
        chain=1:size(pa, 1), 
        param=psymbols 
    )
end

function matrix(ka::KeyedArray, sym::Union{Symbol, String})
    n = string.(axiskeys(ka, :param))
    syms = string(sym)
    sel = String[]
    for (i, s) in enumerate(n)
        if length(s) > length(syms) && syms == n[i][1:length(syms)] &&
            n[i][length(syms)+1] in ['[', '.', '_']
            append!(sel, [n[i]])
        end
    end
    length(sel) == 0 && error("$syms not in $n")
    ka(param=Symbol.(sel))
end

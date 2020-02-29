import .Mamba: AbstractChains, Chains

function convert_a3d(a3d_array, cnames, ::Val{:mambachains}; start=1, kwargs...)

  sr = getindex(a3d_array, [1:1:size(a3d_array, 1);], [1:size(a3d_array, 2);], [1:size(a3d_array, 3);])
  Chains(sr, 1:size(a3d_array, 2), cnames, [i for i in 1:size(a3d_array, 3)])

end

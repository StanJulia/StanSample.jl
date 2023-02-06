module MCMCChainsExt

using StanSample

StanSample.EXTENSIONS_SUPPORTED ? (using MCMCChains) : (using ..MCMCChains)

import StanSample: convert_a3d

function StanSample.convert_a3d(a3d_array, cnames, ::Val{:mcmcchains};
  start=1,
  kwargs...)
  cnames = String.(cnames)
  pi = filter(p -> length(p) > 2 && p[end-1:end] == "__", cnames)
  p = filter(p -> !(p in  pi), cnames)

  MCMCChains.Chains(a3d_array[start:end,:,:],
    cnames,
    Dict(
      :parameters => p,
      :internals => pi
    );
    start=start
  )
end

end
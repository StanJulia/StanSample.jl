using MCMCChains, Random, Distributions

function convert_a3d(a3d_array, cnames; start=1)
  cnames = String.(cnames)

  MCMCChains.Chains(a3d_array[start:end,:,:],
    cnames,
    Dict(
      :parameters => cnames,
      :internals => []
    );
    start=start
  )
end

N=100
cnames = ["mu", "sigma"]
a3d = zeros(N, 2, 4)
for i in 1:4
    a3d[:,:, i] = hcat(rand(Normal(-1, 1), N), rand(Normal(0.1, 0.1), N))
end

chains_01 = convert_a3d(a3d, cnames)
chains_01 |> display

chains_02 = convert_a3d(a3d, cnames)
chains_02 |> display

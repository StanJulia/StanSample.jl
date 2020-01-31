using .MonteCarloMeasurements

function convert_a3d(a3d_array, cnames, ::Val{:particles};
    start=1, kwargs...)

  pi = filter(p -> length(p) > 2 && p[end-1:end] == "__", cnames)
  p = filter(p -> !(p in  pi), cnames)

  d = Dict{Symbol, typeof(Particles(size(df, 1), Normal(0.0, 1.0)))}()

  for var in names(df)
    dens = kde(df[:, var])
    mu = collect(dens.x)[findmax(dens.density)[2]]
    sigma = std(df[:, var], mean=mu)
    d[var] = Particles(size(df, 1), Normal(mu, sigma))
  end

  d

end

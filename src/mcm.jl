using .MonteCarloMeasurements

import .MonteCarloMeasurements: Particles

function convert_a3d(a3d_array, cnames, ::Val{:particles};
    start=1, kwargs...)
  
  df = convert_a3d(a3d_array, Symbol.(cnames), Val(:dataframe))
  d = Dict{Symbol, typeof(Particles(size(df, 1), Normal(0.0, 1.0)))}()

  for var in Symbol.(names(df))
    mu = mean(df[:, var])
    sigma = std(df[:, var])
    d[var] = Particles(size(df, 1), Normal(mu, sigma))
  end

  (; d...)

end

function Particles(df::DataFrame)

  d = Dict{Symbol, typeof(Particles(size(df, 1), Normal(0.0, 1.0)))}()

  for var in Symbol.(names(df))
    d[var] = Particles(df[:, var])
  end

  (;d...)

end

export
  Particles

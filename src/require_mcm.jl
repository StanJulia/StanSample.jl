using .MonteCarloMeasurements

import .MonteCarloMeasurements: Particles

function convert_a3d(a3d_array, cnames, ::Val{:particles};
    kwargs...)
  
  df = convert_a3d(a3d_array, cnames, Val(:dataframe))
  Particles(df)
end

function Particles(df::DataFrame)

  d = Dict{Symbol, typeof(Particles(size(df, 1), Normal(0.0, 1.0)))}()

  for var in names(df)
    d[var] = Particles(df[:, var])
  end

  (;d...)

end

export
  Particles

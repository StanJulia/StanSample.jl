function create_R_init_files(sm::StanModel, init::T, num_chains::Int) where {T <: Vector}
  if length(init) == num_chains
    for (i, d) in enumerate(init)
      stan_dump(sm.output.output_base*"_init_$i.R", d, force=true)
    end
  else
    @info "Data vector length does not match number of chains,"
    @info "only first element in data vector will be used,"
    for i in 1:num_chains
      stan_dump(sm.output.output_base*"_init_$i.R", init[1], force=true)
    end
  end
end

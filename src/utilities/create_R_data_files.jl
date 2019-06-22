function create_R_data_files(sm::StanModel, data::T, nchains::Int) where {T <: Vector}
  if length(data) == nchains
    for (i, d) in enumerate(data)
      stan_dump(default_output_base(sm)*"_data_$i.R", d, force=true)
    end
  else
    @info "Data vector length does not match number of chains,"
    @info "only first element in data vector will be used,"
    for i in 1:nchains
      stan_dump(default_output_base(sm)*"_data_$i.R", data[1], force=true)
    end
  end
end

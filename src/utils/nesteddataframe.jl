function convert_a3d(a3d_array, cnames, ::Val{:nesteddataframe})
    df = convert_a3d(a3d_array, cnames, Val(:dataframe))
    dct = StanSample.parse_header(names(df))
    return StanSample.stan_variables(dct, df)
end

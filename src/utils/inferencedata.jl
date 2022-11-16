function inferencedata(m::SampleModel;
    include_warmup = m.save_warmup,
    log_likelihood_symbol::Union{Nothing, Symbol} = :log_lik,
    posterior_predictive_symbol::Union{Nothing, Symbol} = :y_hat,
    kwargs...)

    stan_nts = read_samples(m, :namedtuples; include_internals=true)

    sample_stats_key_map = (
        n_leapfrog__=:n_steps,
        treedepth__=:tree_depth,
        energy__=:energy,
        lp__=:lp,
        stepsize__=:step_size,
        divergent__=:diverging,
        accept_stat__=:acceptance_rate,
    );

    if !isnothing(log_likelihood_symbol)
        sample_nts = NamedTuple{filter(∉([log_likelihood_symbol]), keys(stan_nts))}(stan_nts)
    end
    
    if !isnothing(posterior_predictive_symbol)
        sample_nts = NamedTuple{filter(∉([posterior_predictive_symbol]), keys(sample_nts))}(sample_nts)
    end

    sample_nts = NamedTuple{filter(∉(keys(sample_stats_key_map)), keys(sample_nts))}(sample_nts)

    stan_stats_nts = NamedTuple{filter(∈(keys(sample_stats_key_map)), keys(stan_nts))}(stan_nts)

    stan_stats_nts_rekey = 
        NamedTuple{map(Base.Fix1(getproperty, sample_stats_key_map), keys(stan_stats_nts))}(
            values(stan_stats_nts))

    idata = from_namedtuple(sample_nts; sample_stats=stan_stats_nts_rekey)

    if posterior_predictive_symbol in keys(stan_nts)
        nt = (y = stan_nts[posterior_predictive_symbol],)
        idata = merge(idata, from_namedtuple(nt; posterior_predictive = (:y,)))
    end

    if log_likelihood_symbol in keys(stan_nts)
        nt = (y = stan_nts[log_likelihood_symbol],)
        idata = merge(idata, from_namedtuple(nt; log_likelihood = (:y,)))
    end

    if include_warmup
        idata = let
            idata_warmup = idata[draw=1:1000]
            idata_postwarmup = idata[draw=1001:2000]
            idata_warmup_rename = InferenceData(NamedTuple(Symbol("warmup_$k") => idata_warmup[k] for k in
                keys(idata_warmup)))
            merge(idata_postwarmup, idata_warmup_rename)
        end
    end

    return idata
end

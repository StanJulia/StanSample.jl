function inferencedata(m::SampleModel;
    include_warmup = m.save_warmup,
    log_likelihood_symbol::Union{Nothing, Symbol} = :log_lik,
    posterior_predictive_symbol::Union{Nothing, Symbol} = :y_hat,
    kwargs...)

    stan_nts = read_samples(m, :namedtuples; include_internals=true)

    #=
    if :y_hat in keys(stan_nts)
        y_hat_nts = stan_nts[[:y_hat]]
        stan_nts = NamedTuple{filter(∉([:y_hat]), keys(stan_nts))}(stan_nts)
    end

    if :log_lik in keys(stan_nts)
        log_lik_nts = stan_nts[[:log_lik]]
        stan_nts = NamedTuple{filter(∉([:log_lik]), keys(stan_nts))}(stan_nts)
    end
    =#

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
        idata_pp = from_namedtuple(stan_nts[[posterior_predictive_symbol]];
            posterior_predictive = (:y_hat,))
        predictive_key_map = (y_hat=:y,)
        predictive_rekey = InferenceObjects.Dataset((; (predictive_key_map[k] => idata_pp.posterior_predictive[k]
            for k in keys(idata_pp.posterior_predictive))...));
        idata_pp = merge(idata_pp, InferenceData(; posterior_predictive=predictive_rekey))
        idata = merge(idata, idata_pp)
    end

    if :log_lik in keys(stan_nts)
        idata_ll = from_namedtuple(stan_nts[[:log_lik]]; log_likelihood = (:log_lik,))
        log_lik_key_map = (log_lik=:y,)
        log_lik_rekey = InferenceObjects.Dataset((; (log_lik_key_map[k] => idata_ll.log_likelihood[k] for k in
            keys(idata_ll.log_likelihood))...));
        idata_ll = merge(idata, InferenceData(; log_likelihood=log_lik_rekey))
        idata = merge(idata, idata_ll)
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

function inferencedata(m::SampleModel; kwargs...)

    # Used keyword arguments
    used_keywords = [:include_log_likelihood, :include_sample_stats,
        :include_posterior_predictive]

    # Default is only posterior values
    include_log_likelihood = false
    include_sample_stats = false
    include_posterior_predictive = false

    # Warmup included if stored
    include_warmup = m.save_warmup

    for (indx, kwd) in enumerate(kwargs)
        if kwd[1] == :include_log_likelihood
            include_log_likelihood = kwargs[indx][1] ? true : false
        end
        if kwd[1] == :include_sample_stats
            include_sample_stats = kwargs[indx][1] ? true : false
        end
        if kwd[1] == :include_posterior_predictive
            include_posterior_predictive = kwargs[indx][1] ? true : false
        end
    end

    stan_nts = read_samples(m, :namedtuples; include_internals=include_sample_stats)
    idata = from_namedtuple(stan_nts[[:mu, :theta_tilde, :theta, :tau]])

    if include_posterior_predictive
        idata_pp = from_namedtuple(stan_nts[[:mu, :theta_tilde, :theta, :tau, :y_hat]];
            posterior_predictive = (:y_hat,))
        predictive_key_map = (y_hat=:y,)
        predictive_rekey = InferenceObjects.Dataset((; (predictive_key_map[k] => idata_pp.posterior_predictive[k]
            for k in keys(idata_pp.posterior_predictive))...));
        idata_pp = merge(idata_pp, InferenceData(; posterior_predictive=predictive_rekey))
        idata = merge(idata, idata_pp)
    end

    if include_sample_stats
        idata_ss = from_namedtuple(stan_nts[[:mu, :theta_tilde, :theta, :tau, :treedepth__, :energy__,
            :divergent__, :accept_stat__, :n_leapfrog__, :lp__, :stepsize__]];
            sample_stats = (:treedepth__, :energy__, :divergent__, :accept_stat__, :n_leapfrog__,
                :lp__, :stepsize__))

        stan_key_map = (
            n_leapfrog__=:n_steps,
            treedepth__=:tree_depth,
            energy__=:energy,
            lp__=:lp,
            stepsize__=:step_size,
            divergent__=:diverging,
            accept_stat__=:acceptance_rate,
        );
        
        sample_stats_rekey = InferenceObjects.Dataset((; (stan_key_map[k] => idata_ss.sample_stats[k] for k in 
            keys(idata_ss.sample_stats))...));
        idata_ss = merge(idata_ss, InferenceData(; sample_stats=sample_stats_rekey))
        idata = merge(idata, idata_ss)
    end

    if include_log_likelihood
        idata_ll = from_namedtuple(stan_nts[[:mu, :theta_tilde, :theta, :tau, :log_lik]]; 
            log_likelihood = (:log_lik,))
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

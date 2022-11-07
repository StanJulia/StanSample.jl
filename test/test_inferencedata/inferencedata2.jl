function inferencedata2(m::SampleModel; kwargs...)

    # Used keyword arguments
    used_keywords = [:include_internals]
    include_internals = false
    include_warmup = false
    for (indx, kwd) in enumerate(kwargs)
        if kwd[1] == :include_internals
            include_internals = kwargs[indx][1] ? true : false
        end
        if kwd[1] == :include_warmup
            include_warmup = kwargs[indx][1] ? true : false
        end
    end

    stan_nts = read_samples(m, :namedtuples; include_internals)

    idata_posterior = from_namedtuple(stan_nts[[:mu, :theta_tilde, :theta, :tau]])
    idata_predictive = from_namedtuple(stan_nts;
        posterior_predictive = (:y_hat,), 
        sample_stats = (:treedepth__, :energy__, :divergent__, :accept_stat__, :n_leapfrog__, :lp__, :stepsize__),
        log_likelihood = (:log_lik,), )

    idata = merge(idata_posterior, idata_predictive)

    return idata
end

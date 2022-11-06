using InferenceObjects
using PosteriorDB

import Base: convert

"""

# inference

# Convert the output file(s) created by cmdstan to a InferenceData object.

$(SIGNATURES)

"""
function inferencedata(m::SampleModel; kwargs...)

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

    idata = from_namedtuple(
        stan_nts;
        posterior_predictive = (:y_hat,), 
        sample_stats = (:treedepth__, :energy__, :divergent__, :accept_stat__, :n_leapfrog__, :lp__, :stepsize__),
        log_likelihood = (:log_lik,), )

        predictive_key_map = (
        y_hat=:y,
    )

    predictive_rekey = InferenceObjects.Dataset((; (predictive_key_map[k] => idata.posterior_predictive[k] for k in     keys(idata.posterior_predictive))...));
    idata2 = merge(idata, InferenceData(; posterior_predictive=predictive_rekey))

    log_lik_key_map = (
        log_lik=:y,
    )
    log_lik_rekey = InferenceObjects.Dataset((; (log_lik_key_map[k] => idata2.log_likelihood[k] for k in        keys(idata2.log_likelihood))...));
    idata2 = merge(idata2, InferenceData(; log_likelihood=log_lik_rekey))

    if include_internals
        stan_key_map = (
            n_leapfrog__=:n_steps,
            treedepth__=:tree_depth,
            energy__=:energy,
            lp__=:lp,
            stepsize__=:step_size,
            divergent__=:diverging,
            accept_stat__=:acceptance_rate,
        );
        
        sample_stats_rekey = InferenceObjects.Dataset((; (stan_key_map[k] => idata2.sample_stats[k] for k in 
            keys(idata.sample_stats))...));
        idata2 = merge(idata2, InferenceData(; sample_stats=sample_stats_rekey))
    end

    if include_warmup
        idata3 = let
           idata_warmup = idata2[draw=1:1000]
           idata_postwarmup = idata2[draw=1001:2000]
           idata_warmup_rename = InferenceData(NamedTuple(Symbol("warmup_$k") => idata_warmup[k] for k in keys(idata_warmup)))
           merge(idata_postwarmup, idata_warmup_rename)
       end

        return idata3  
    else
        return idata2
    end     

end

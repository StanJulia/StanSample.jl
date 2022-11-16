function inferencedata(m::SampleModel;
    include_warmup = m.save_warmup,
    log_likelihood_symbol::Union{Nothing, Symbol} = :log_lik,
    posterior_predictive_symbol::Union{Nothing, Symbol} = :y_hat,
    kwargs...)

    # Read in the draws as a NamedTuple with sample_stats included
    stan_nts = read_samples(m, :namedtuples; include_internals=true)

    # Define the "proper" ArviZ names for the sample statistics group.
    sample_stats_key_map = (
        n_leapfrog__=:n_steps,
        treedepth__=:tree_depth,
        energy__=:energy,
        lp__=:lp,
        stepsize__=:step_size,
        divergent__=:diverging,
        accept_stat__=:acceptance_rate,
    );

    # If a log_likelihood_symbol is defined (!= nothing), remove it from the future posterior group
    if !isnothing(log_likelihood_symbol)
        sample_nts = NamedTuple{filter(∉([log_likelihood_symbol]), keys(stan_nts))}(stan_nts)
    end

    # If a posterior_predictive_symbol is defined (!= nothing), remove it from the future posterior group
    if !isnothing(posterior_predictive_symbol)
        sample_nts = NamedTuple{filter(∉([posterior_predictive_symbol]), keys(sample_nts))}(sample_nts)
    end

    # `sample_nts` now holds remaining parameters and the sample statistics
    # Split in 2 separate NamedTuples: posterior_nts and sample_stats_nts
    posterior_nts = NamedTuple{filter(∉(keys(sample_stats_key_map)), keys(sample_nts))}(sample_nts)
    sample_stats_nts = NamedTuple{filter(∈(keys(sample_stats_key_map)), keys(sample_nts))}(sample_nts)

    # Remap the names according to above sample_stats_key_map
    sample_stats_nts_rekey = 
        NamedTuple{map(Base.Fix1(getproperty, sample_stats_key_map), keys(sample_stats_nts))}(
            values(sample_stats_nts))

    # Create initial inferencedata object with 2 groups
    idata = from_namedtuple(sample_nts; sample_stats=sample_stats_nts_rekey)

    # Merge both log_likelihood and posterior_predictive groups into idata if present
    if !isnothing(posterior_predictive_symbol) && posterior_predictive_symbol in keys(stan_nts)
        nt = (y = stan_nts[posterior_predictive_symbol],)
        idata = merge(idata, from_namedtuple(nt; posterior_predictive = (:y,)))
    end

    if !isnothing(log_likelihood_symbol) log_likelihood_symbol in keys(stan_nts)
        nt = (y = stan_nts[log_likelihood_symbol],)
        idata = merge(idata, from_namedtuple(nt; log_likelihood = (:y,)))
    end

    # Extract warmup values in separate groups
    if include_warmup
        idata = let
            idata_warmup = idata[draw=1:1000]
            idata_postwarmup = idata[draw=1001:2000]
            idata_warmup_rename = InferenceData(NamedTuple(Symbol("warmup_$k") => idata_warmup[k] for k in
                keys(idata_warmup)))
            merge(idata_postwarmup, idata_warmup_rename)
        end
    end

    # TO DO: update the indexing

    # TO DO: add other groups (data, etc.)

    return idata
end

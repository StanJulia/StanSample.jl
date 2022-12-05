"""

Create an inferencedata object from a SampleModel.

$(SIGNATURES)

# Extended help

### Required arguments
```julia
* `m::SampleModel`                     # SampleModel object
```

### Optional positional argument
```julia
* `include_warmup`                     # Directory where output files are stored
* `log_likelihood_symbol`              # Symbol used for log_likelihood (or nothing, default: :log_lik)
* `posterior_predictive_symbol`        # Symbol used for posterior_predictive (or nothing, default: :y_hat)
* `kwargs...`                          # Arguments to pass on to `from_namedtuple`
```

### Returns
```julia
* `inferencedata object`               # Will at least contain posterior and sample_stats groups
```

See the example in ./test/test_inferencedata.jl. 

Note that this function is currently under development.

"""
function inferencedata3(m::SampleModel;
    include_warmup = m.save_warmup,
    log_likelihood_symbol::Union{Nothing, Symbol} = :log_lik,
    posterior_predictive_symbol::Union{Nothing, Symbol} = :y_hat,
    kwargs...)

    # Read in the draws as a NamedTuple with sample_stats included
    stan_nts = read_samples(m, :namedtuples; include_internals=true)
    
    # Convert to a Dict and split into draws and warmup Dicts 
    # When creating the new Dicts, update sample_stats names
    initial_dict = convert(Dict, stan_nts)
    posterior_dict = Dict{Symbol, Any}()
    warmup_posterior_dict = Dict{Symbol, Any}()
    if include_warmup
        for key in keys(initial_dict)
            if length(size(initial_dict[key])) == 1
                warmup_posterior_dict[arviz_names(key)] = initial_dict[key][1:m.num_warmups]
                posterior_dict[arviz_names(key)] = initial_dict[key][(m.num_warmups+1):end]
            elseif length(size(initial_dict[key])) == 2
                warmup_posterior_dict[arviz_names(key)] = initial_dict[key][1:m.num_warmups, :]
                posterior_dict[arviz_names(key)] = initial_dict[key][(m.num_warmups+1):end, :]
            elseif length(size(initial_dict[key])) == 3
                warmup_posterior_dict[arviz_names(key)] = initial_dict[key][:, 1:m.num_warmups, :]
                posterior_dict[arviz_names(key)] = initial_dict[key][:, (m.num_warmups+1):end, :]
            end
        end
    end

    # In `inferencedata2()` the Dicts were converted back to NamedTuples
    # This version (`inferencedata3()`) uses `from_dict)` directly
    
    # If a log_likelihood_symbol is defined, extract and remove it from the future posterior groups
    if !isnothing(log_likelihood_symbol)
        log_likelihood_dict = Dict{Symbol, Any}()
        warmup_log_likelihood_dict = Dict{Symbol, Any}()
        if log_likelihood_symbol in keys(posterior_dict)
            log_likelihood_dict[:y] = posterior_dict[log_likelihood_symbol]
            delete!(posterior_dict, log_likelihood_symbol)
            warmup_log_likelihood_dict[:y] = warmup_posterior_dict[log_likelihood_symbol]
            delete!(warmup_posterior_dict, log_likelihood_symbol)
        end
    end

    # If a posterior_predictive_symbol is defined, extract and remove it from the future posterior group
    if !isnothing(posterior_predictive_symbol)
        posterior_predictive_dict = Dict{Symbol, Any}()
        warmup_posterior_predictive_dict = Dict{Symbol, Any}()
        if posterior_predictive_symbol in keys(posterior_dict)
            posterior_predictive_dict[:y] = posterior_dict[posterior_predictive_symbol]
            delete!(posterior_dict, posterior_predictive_symbol)
            warmup_posterior_predictive_dict[:y] = warmup_posterior_dict[posterior_predictive_symbol]
            delete!(warmup_posterior_dict, posterior_predictive_symbol)
        end
   end

    # `posterior_dict` and `warmup_dict` now holds remaining parameters and the sample statistics
    # Extract and remove sample_stats from draw and warmup dicts and store in [warmup_]sample_stats_dict
    sample_stats_keys = (:n_steps, :tree_depth, :energy, :lp, :step_size, :diverging, :acceptance_rate)
    sample_stats_dict = Dict{Symbol, Any}()
    warmup_sample_stats_dict = Dict{Symbol, Any}()
    for key in keys(posterior_dict)
        if key in sample_stats_keys
            sample_stats_dict[key] = posterior_dict[key]
            delete!(posterior_dict, key)
            warmup_sample_stats_dict[key] = warmup_posterior_dict[key]
            delete!(warmup_posterior_dict, key)
        end
    end

    # Create initial inferencedata object with 2 groups (posterior and sample_stats)
    idata = from_dict(posterior_dict;
        sample_stats=InferenceObjects.as_namedtuple(sample_stats_dict),
        kwargs...)

    if !isnothing(log_likelihood_symbol)
        idata_ll = from_namedtuple(;
            log_likelihood = InferenceObjects.as_namedtuple(log_likelihood_dict))
        idata = merge(idata, idata_ll)
    end
    
    if !isnothing(posterior_predictive_symbol)
        idata_pp = from_namedtuple(;
            posterior_predictive = InferenceObjects.as_namedtuple(posterior_predictive_dict))
        idata = merge(idata, idata_pp)
    end
    
    # Add warmup groups if so desired
    if include_warmup
        # Create initial warmup inferencedata object with 2 groups
        idata_warmup = from_dict(warmup_posterior_dict;
            sample_stats=InferenceObjects.as_namedtuple(warmup_sample_stats_dict), 
            kwargs...)

        # Merge both log_likelihood and posterior_predictive groups into idata_warmup if present
        if !isnothing(posterior_predictive_symbol) && posterior_predictive_symbol in keys(initial_dict)
            nt = (y = warmup_posterior_predictive_dict[:y],)
            idata_warmup = merge(idata_warmup, from_namedtuple(; posterior_predictive = nt, kwargs...))
        end
    
        if !isnothing(log_likelihood_symbol) log_likelihood_symbol in keys(initial_dict)
            nt = (y = warmup_log_likelihood_dict[:y],)
            idata_warmup = merge(idata_warmup, from_namedtuple(; log_likelihood = nt, kwargs...))
        end

        idata_warmup_rename =
            InferenceData(NamedTuple(Symbol("warmup_$k") => idata_warmup[k] for k in keys(idata_warmup)))
        idata = merge(idata, idata_warmup_rename)
    end
        
    return idata
end
using .InferenceObjects

const SymbolOrSymbols = Union{Symbol, AbstractVector{Symbol}, NTuple{N, Symbol} where N}

# Define the "proper" ArviZ names for the sample statistics group.
const SAMPLE_STATS_KEY_MAP = (
    n_leapfrog__=:n_steps,
    treedepth__=:tree_depth,
    energy__=:energy,
    lp__=:lp,
    stepsize__=:step_size,
    divergent__=:diverging,
    accept_stat__=:acceptance_rate,
)

function split_nt(nt::NamedTuple, ks::NTuple{N, Symbol}) where {N}
    keys1 = filter(∉(ks), keys(nt))
    keys2 = filter(∈(ks), keys(nt))
    return NamedTuple{keys1}(nt), NamedTuple{keys2}(nt)
end
split_nt(nt::NamedTuple, key::Symbol) = split_nt(nt, (key,))
split_nt(nt::NamedTuple, ::Nothing) = (nt, nothing)
split_nt(nt::NamedTuple, keys) = split_nt(nt, Tuple(keys))

function split_nt_all(nt::NamedTuple; kwargs...)
    # break recursion
    isempty(kwargs) && return nt, NamedTuple()
    # recursively split
    k, v = first(kwargs)
    nt_main, nt_split = split_nt(nt, v)
    nt_final, nt_split_others = split_nt_all(nt_main; Iterators.drop(kwargs, 1)...)
    return nt_final, merge(NamedTuple{(k,)}((nt_split,)), nt_split_others)
end

function rekey(d::NamedTuple, keymap)
    new_keys = map(k -> get(keymap, k, k), keys(d))
    return NamedTuple{new_keys}(values(d))
end

function inferencedata1(m::SampleModel;
    include_warmup = m.save_warmup,
    log_likelihood_var::Union{SymbolOrSymbols,Nothing} = nothing,
    posterior_predictive_var::Union{SymbolOrSymbols,Nothing} = nothing,
    predictions_var::Union{SymbolOrSymbols,Nothing} = nothing,
    kwargs...,
)

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
    else
        sample_mts = stan_nts
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
    idata = from_namedtuple(posterior_nts; sample_stats=sample_stats_nts_rekey, kwargs...)

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

    return idata
end

function arviz_names(sym::Symbol)
    # Define the "proper" ArviZ names for the sample statistics group.
    sample_stats_key_map = (
        n_leapfrog__=:n_steps,
        treedepth__=:tree_depth,
        energy__=:energy,
        lp__=:lp,
        stepsize__=:step_size,
        divergent__=:diverging,
        accept_stat__=:acceptance_rate,
    )
    if sym in keys(sample_stats_key_map)
        return sample_stats_key_map[sym]
    else
        return sym
    end
end


function inferencedata2(m::SampleModel;
    include_warmup = m.save_warmup,
    log_likelihood_symbol::Union{Nothing, Symbol} = :log_lik,
    posterior_predictive_symbol::Union{Nothing, Symbol} = :y_hat,
    kwargs...)

    # Read in the draws as a NamedTuple with sample_stats included
    stan_nts = read_samples(m, :namedtuples; include_internals=true)
    
    # Convert to a Dict and split into draws and warmup Dicts 
    # When creating the new Dicts, update sample_stats names
    dicts = convert(Dict, stan_nts)
    draw_dict = Dict{Symbol, Any}()
    warmup_dict = Dict{Symbol, Any}()
    if include_warmup
        for key in keys(dicts)
            if length(size(dicts[key])) == 1
                warmup_dict[arviz_names(key)] = dicts[key][1:m.num_warmups]
                draw_dict[arviz_names(key)] = dicts[key][(m.num_warmups+1):end]
            elseif length(size(dicts[key])) == 2
                warmup_dict[arviz_names(key)] = dicts[key][1:m.num_warmups, :]
                draw_dict[arviz_names(key)] = dicts[key][(m.num_warmups+1):end, :]
            elseif length(size(dicts[key])) == 3
                warmup_dict[arviz_names(key)] = dicts[key][:, 1:m.num_warmups, :]
                draw_dict[arviz_names(key)] = dicts[key][:, (m.num_warmups+1):end, :]
            end
        end
    end

    draw_nts = namedtuple(draw_dict)
    warmup_nts = namedtuple(warmup_dict)
    @assert keys(draw_nts) == keys(warmup_nts)
    
    # If a log_likelihood_symbol is defined, remove it from the future posterior groups
    if !isnothing(log_likelihood_symbol)
        sample_nts = NamedTuple{filter(∉([log_likelihood_symbol]), keys(draw_nts))}(draw_nts)
        warm_nts = NamedTuple{filter(∉([log_likelihood_symbol]), keys(warmup_nts))}(warmup_nts)
    else
        sample_nts = draw_nts
        warm_nts = warmup_nts
    end

    # If a posterior_predictive_symbol is defined, remove it from the future posterior group
    if !isnothing(posterior_predictive_symbol)
        sample_nts = NamedTuple{filter(∉([posterior_predictive_symbol]), keys(sample_nts))}(sample_nts)
        warm_nts = NamedTuple{filter(∉([posterior_predictive_symbol]), keys(warm_nts))}(warm_nts)
    end

    # `sample_nts` and `warm_nts` now holds remaining parameters and the sample statistics
    
    # ArviZ names for the sample statistics group
    # Remove from posteriors groups and store in sample_stats groups
    sample_stats_keys = (:n_steps, :tree_depth, :energy, :lp, :step_size, :diverging, :acceptance_rate)
    
    # Split both draws and warmup into 2 separate NamedTuples: posterior_nts and sample_stats_nts
    posterior_nts = NamedTuple{filter(∉(sample_stats_keys), keys(sample_nts))}(sample_nts)
    warmup_posterior_nts = NamedTuple{filter(∉(sample_stats_keys), keys(warm_nts))}(warm_nts)
    
    sample_stats_nts = NamedTuple{filter(∈(sample_stats_keys), keys(sample_nts))}(sample_nts)
    warmup_sample_stats_nts = NamedTuple{filter(∈(sample_stats_keys), keys(warm_nts))}(warm_nts)
    
    # Create initial inferencedata object with 2 groups (posterior and sample_stats)
    idata = from_namedtuple(posterior_nts; sample_stats=sample_stats_nts, kwargs...)

    # Merge both log_likelihood and posterior_predictive groups into idata if present
    # Note that log_likelihood and predictive_posterior NamedTuples are obtained from
    # draw_nts and warmup_nts directly and in the process being renamed to :y
    if !isnothing(posterior_predictive_symbol) && posterior_predictive_symbol in keys(stan_nts)
        nt = (y = draw_nts[posterior_predictive_symbol],)
        idata = merge(idata, from_namedtuple(nt; posterior_predictive = (:y,)))
    end
    
    if !isnothing(log_likelihood_symbol) log_likelihood_symbol in keys(stan_nts)
        nt = (y = draw_nts[log_likelihood_symbol],)
        idata = merge(idata, from_namedtuple(nt; log_likelihood = (:y,)))
    end

    # Add warmup groups if so desired
    if include_warmup
        # Create initial warmup inferencedata object with 2 groups
        idata_warmup = from_namedtuple(
            warmup_posterior_nts,
            sample_stats=warmup_sample_stats_nts, 
            kwargs...)

        # Merge both log_likelihood and posterior_predictive groups into idata_warmup if present
        if !isnothing(posterior_predictive_symbol) && posterior_predictive_symbol in keys(stan_nts)
            nt = (y = warmup_nts[posterior_predictive_symbol],)
            idata_warmup = merge(idata_warmup, from_namedtuple(; posterior_predictive = nt, kwargs...))
        end
    
        if !isnothing(log_likelihood_symbol) log_likelihood_symbol in keys(stan_nts)
            nt = (y = warmup_nts[log_likelihood_symbol],)
            idata_warmup = merge(idata_warmup, from_namedtuple(; log_likelihood = nt, kwargs...))
        end

        idata_warmup_rename = InferenceData(NamedTuple(Symbol("warmup_$k") => idata_warmup[k] for k in keys(idata_warmup)))
        idata = merge(idata, idata_warmup_rename)
    end

    return idata
end

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
inferencedata = inferencedata3

export
    inferencedata

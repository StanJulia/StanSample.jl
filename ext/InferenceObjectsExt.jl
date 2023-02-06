module InferenceObjectsExt

using StanSample, DocStringExtensions

StanSample.EXTENSIONS_SUPPORTED ? (using InferenceObjects) : (using ..InferenceObjects)

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

function split_nt_all(nt::NamedTuple, pair::Pair{Symbol}, others::Pair{Symbol}...)
    group_name, keys = pair
    nt_main, nt_group = split_nt(nt, keys)
    post_nt, groups_nt_others = split_nt_all(nt_main, others...)
    groups_nt = NamedTuple{(group_name,)}((nt_group,))
    return post_nt, merge(groups_nt, groups_nt_others)
end

split_nt_all(nt::NamedTuple) = (nt, NamedTuple())

function rekey(d::NamedTuple, keymap)
    new_keys = map(k -> get(keymap, k, k), keys(d))
    return NamedTuple{new_keys}(values(d))
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
* `include_warmup`                  # Directory where output files are stored
* `log_likelihood_var`              # Symbol(s) used for log_likelihood (or nothing)
* `posterior_predictive_var`        # Symbol(s) used for posterior_predictive (or nothing)
* `predictions_var`                 # Symbol(s) used for predictions (or nothing)
* `kwargs...`                       # Arguments to pass on to `from_namedtuple`
```

### Returns
```julia
* `inferencedata object`               # Will at least contain posterior and sample_stats groups
```

See the example in ./test/test_inferencedata.jl. 

Note that this function is currently under development.

"""
function StanSample.inferencedata(m::SampleModel;
    include_warmup = m.save_warmup,
    log_likelihood_var::Union{SymbolOrSymbols,Nothing} = nothing,
    posterior_predictive_var::Union{SymbolOrSymbols,Nothing} = nothing,
    predictions_var::Union{SymbolOrSymbols,Nothing} = nothing,
    kwargs...,
)

    # Read in the draws as a NamedTuple with sample_stats included
    stan_nts = read_samples(m, :permuted_namedtuples; include_internals=true)

    # split stan_nts into separate groups based on keyword arguments
    posterior_nts, group_nts = split_nt_all(
        stan_nts,
        :sample_stats => keys(SAMPLE_STATS_KEY_MAP),
        :log_likelihood => log_likelihood_var,
        :posterior_predictive => posterior_predictive_var,
        :predictions => predictions_var,
    )
    # Remap the names according to above SAMPLE_STATS_KEY_MAP
    sample_stats = rekey(group_nts.sample_stats, SAMPLE_STATS_KEY_MAP)
    group_nts_stats_rename = merge(group_nts, (; sample_stats=sample_stats))

    # Create initial inferencedata object with 2 groups
    idata = from_namedtuple(posterior_nts; group_nts_stats_rename..., kwargs...)

    # Extract warmup values in separate groups
    if include_warmup
        warmup_indices = 1:m.num_warmups
        sample_indices = (1:m.num_samples) .+ m.num_warmups
        idata = let
            idata_warmup = idata[draw=warmup_indices]
            idata_postwarmup = idata[draw=sample_indices]
            idata_warmup_rename = InferenceData(NamedTuple(Symbol("warmup_$k") => idata_warmup[k] for k in
                keys(idata_warmup)))
            merge(idata_postwarmup, idata_warmup_rename)
        end
    end

    return idata
end

end


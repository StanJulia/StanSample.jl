"""

stan_sample()

Draw from a StanJulia SampleModel (<: CmdStanModel.)

## Required argument
```julia
* `m <: CmdStanModels`                 # SampleModel.
```

### Most frequently used keyword arguments
```julia
* `data`                               # Observations Dict or NamedTuple.
* `init`                               # Init Dict or NT (default: -2 to +2).
```

### Returns
```julia
* `rc`                                 # Return code, 0 is success.
```

See extended help for other keyword arguments ( `??stan_sample` ).

# Extended help

### Additional configuration keyword arguments
```julia
* `num_chains=4`                       # Update number of chains.
* `num_threads=8`                      # Update number of threads.

* `num_samples=1000`                   # Number of samples.
* `num_warmups=1000`                   # Number of warmup samples.
* `save_warmup=false`                  # Save warmup samples.

* `thin=1`                             # Set thinning value.
* `seed=-1`                            # Set seed value.

* `engaged=true`                       # Adaptation engaged.
* `gamma=0.05`                         # Adaptation regularization scale.
* `delta=0.8`                          # Adaptation target acceptance statistic.
* `kappa=0.75`                         # Adaptation relaxation exponent.
* `t0=10`                              # Adaptation iteration offset.
* `init_buffer=75`                     # Inital adaptation interval.
* `term_buffer=50`                     # Final fast adaptation interval.
* `window=25`                          # Initia; slow adaptation interval.

* `algorithm=:hmc`                     # Sampling algorithm.
* `engine=:nuts`                       # :nuts or :static.
* `max_depth=10`                       # Max tree depth for :nuts engine.
* `int_time=2 * pi`                    # Integration time for :static engine.

* `metric=:diag_e`                     # Geometry of manifold setting:
                                       # :diag_e, :unit_e or :dense_e.
* `metric_file=""`                     # Precompiled Euclidean metric.
* `stepsize=1.0`                       # Step size for discrete evolution
* `stepsize_jitter=0.0`                # Random jitter on step size ( [%] )

* `summary=true`                       # Create stansummary .csv file
* `print_summary=false`                # Display summary
```
"""
function stan_run(m::T; kwargs...) where {T <: CmdStanModels}

    handle_keywords!(m, kwargs)
    
    # Diagnostics files requested?
    diagnostics = false
    if :diagnostics in keys(kwargs)
        diagnostics = kwargs[:diagnostics]
        setup_diagnostics(m, m.num_chains)
    end

    # Remove existing sample files
    for id in 1:m.num_chains
        sfile = sample_file_path(m.output_base, id)
        isfile(sfile) && rm(sfile)
    end

    :init in keys(kwargs) && update_R_files(m, kwargs[:init],
        m.num_chains, "init")
    :data in keys(kwargs) && update_R_files(m, kwargs[:data],
        m.num_chains, "data")

    m.cmds = [stan_cmds(m, id; kwargs...) for id in 1:m.num_chains]

    #println(typeof(m.cmds))
    #println()
    #println(m.cmds)

    run(pipeline(par(m.cmds), stdout=m.log_file[1]))
    #run.(pipeline(m.cmds, stdout=m.log_file[1]))
end

"""

Generate a cmdstan command line (a run `cmd`).

$(SIGNATURES)

Internal, not exported.
"""
function stan_cmds(m::T, id::Integer; kwargs...) where {T <: CmdStanModels}
    append!(m.sample_file, [sample_file_path(m.output_base, id)])
    append!(m.log_file, [log_file_path(m.output_base, id)])
    if length(m.diagnostic_file) > 0
      append!(m.diagnostic_file, [diagnostic_file_path(m.output_base, id)])
    end
    cmdline(m, id)
end

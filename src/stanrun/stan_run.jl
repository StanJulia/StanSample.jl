"""

stan_sample()

Draw from a StanJulia SampleModel (<: CmdStanModel.)

## Required argument
```julia
* `m <: CmdStanModels`                 # SampleModel
* `use_json=true`                      # Set to false for .R data files.
                                       # Currently init.R files are rejected.
* `check_num_chains=true`              # Check for C++ chains or Julia level chains
```

### Most frequently used keyword arguments
```julia
* `data`                               # Observations Dict or NamedTuple.
* `init`                               # Init Dict or NT (default: -2 to +2).
```

See extended help for other keyword arguments ( `??stan_sample` ).

### Returns
```julia
* `rc`                                 # Return code, 0 is success.
```

# Extended help

### Additional configuration keyword arguments
```julia
* `num_threads=4`                      # Update number of c++ threads.
* `num_cpp_chains=1`                   # Update number of c++ chains.
* `num_julia_chains=1`                 # Update number of Julia chains.
                                       # Both initialized from num_chains

* `use_cpp_chains=false`               # Run num_chains on c++ level
                                       # Set to false to use Julia processes

* `num_chains=4`                       # Actual number of chains.
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

Note: Currently I do not suggest to use both C++ level chains and Julia
level chains. By default, based on  `use_cpp_chains` the `stan_sample()` 
method will set either `num_cpp_chains=num_chains; num_julia_chains=1` 
(the default) or `num_julia_chains=num_chains;num_cpp_chain=1`. Set the 
postional `check_num_chains` argument in the call to `stan_sample()` to 
`false` to prevent this default behavior.

Threads on C++ level can be used in multiple ways, e.g. to run separate 
chains and to speed up certain operations. By default StanSample.jl's 
SampleModel sets the C++ num_threads to 4. See the `graphs` subdirectory
in the RedCardsStudy in the Examples directory for an example.

"""
function stan_run(m::T, 
    use_json=true,
    check_num_chains=true;
    kwargs...) where {T <: CmdStanModels}

    handle_keywords!(m, kwargs, check_num_chains)
    
    # Diagnostics files requested?
    diagnostics = false
    if :diagnostics in keys(kwargs)
        diagnostics = kwargs[:diagnostics]
        setup_diagnostics(m, m.num_julia_chains)
    end

    # Remove existing sample files
    if m.use_cpp_chains
            sfile = m.output_base  * "_chain.csv"
            isfile(sfile) && rm(sfile)
    else
        for id in 1:m.num_julia_chains
            sfile = sample_file_path(m.output_base, id)
            isfile(sfile) && rm(sfile)
        end
    end

    m.data_file = String[]
    m.init_file = String[]
    if use_json
        :init in keys(kwargs) && update_json_files(m, kwargs[:init],
            m.num_julia_chains, "init")
        :data in keys(kwargs) && update_json_files(m, kwargs[:data],
            m.num_julia_chains, "data")
    else
        :init in keys(kwargs) && update_R_files(m, kwargs[:init],
            m.num_julia_chains, "init")
        :data in keys(kwargs) && update_R_files(m, kwargs[:data],
            m.num_julia_chains, "data")
    end

    m.sample_file = String[]
    m.log_file = String[]
    m.diagnostic_file = String[]
    m.cmds = [stan_cmds(m, id, check_num_chains; kwargs...) for id in 1:m.num_julia_chains]

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
function stan_cmds(m::T, id::Integer, check_num_chains::Bool; kwargs...) where {T <: CmdStanModels}
    if m.use_cpp_chains && check_num_chains
        append!(m.sample_file, [m.output_base  * "_chain.csv"])
    else
        for id in 1:m.num_julia_chains
            append!(m.sample_file, [sample_file_path(m.output_base, id)])
        end
    end
    append!(m.log_file, [log_file_path(m.output_base, id)])
    if length(m.diagnostic_file) > 0
      append!(m.diagnostic_file, [diagnostic_file_path(m.output_base, id)])
    end
    cmdline(m, id)
end

"""

Construct command line for chain id.

$(SIGNATURES)

### Required arguments
```julia
* `m::SampleModel`                     : SampleModel
* `id::Int`                            : Chain id
``` 
Not exported
"""
function cmdline(m::SampleModel, id; kwargs...)
  
    cmd = ``
    # Handle the model name field for unix and windows
    cmd = `$(m.exec_path)`

    if m.use_cpp_chains
        cmd = :num_threads in keys(kwargs) ? `$cmd num_threads=$(m.num_threads)` : `$cmd`
        cmd = `$cmd sample num_chains=$(m.num_cpp_chains)`
    else
        cmd = `$cmd sample`
    end

    cmd = :num_samples in keys(kwargs) ? `$cmd num_samples=$(m.num_samples)` : `$cmd`
    cmd = :num_warmup in keys(kwargs) ? `$cmd num_warmup=$(m.num_warmups)` : `$cmd`
    cmd = :save_warmup in keys(kwargs) ? `$cmd save_warmup=$(m.save_warmup)` : `$cmd`
    cmd = :save_warmup in keys(kwargs) ? `$cmd thin=$(m.thin)` : `$cmd`
    cmd = `$cmd adapt engaged=$(m.engaged)`
    cmd = :gamma in keys(kwargs) ? `$cmd gamma=$(m.gamma)` : `$cmd`
    cmd = :delta in keys(kwargs) ? `$cmd delta=$(m.delta)` : `$cmd`
    cmd = :kappa in keys(kwargs) ? `$cmd kappa=$(m.kappa)` : `$cmd`
    cmd = :t0 in keys(kwargs) ? `$cmd t0=$(m.t0)` : `$cmd`
    cmd = :init_buffer in keys(kwargs) ? `$cmd init_buffer=$(m.init_buffer)` : `$cmd`
    cmd = :term_buffer in keys(kwargs) ? `$cmd term_buffer=$(m.term_buffer)` : `$cmd`
    cmd = :window in keys(kwargs) ? `$cmd window=$(m.window)` : `$cmd`
    cmd = :save_metric in keys(kwargs) ? `$cmd save_metric=$(m.save_metric)` : `$cmd`

    # Algorithm section
    cmd = :algorithm in keys(kwargs) ? `$cmd algorithm=$(string(m.algorithm))` : `$cmd`
    if m.algorithm == :hmc
        cmd = :engine in keys(kwargs) ? `$cmd engine=$(string(m.engine))` : `$cmd`
        if m.engine == :nuts
            cmd = :max_depth in keys(kwargs) ? `$cmd nuts max_depth=$(m.max_depth)` : `$cmd`
        elseif m.engine == :static
            cmd = :int_time in keys(kwargs) ? `$cmd int_time=$(m.int_time)` : `$cmd`
        end
        cmd = :metric in keys(kwargs) ? `$cmd metric=$(string(m.metric))` : `$cmd`
        cmd = :stepsize in keys(kwargs) ? `$cmd stepsize=$(m.stepsize)` : `$cmd`
        cmd = :stepsize_jitter in keys(kwargs) ? `$cmd stepsize_jitter=$(m.stepsize_jitter)` : `$cmd`
    end

    cmd = `$cmd id=$(id)`

    # Data file required?
    if length(m.data_file) > 0 && isfile(m.data_file[id])
      cmd = `$cmd data file=$(m.data_file[id])`
    end

    # Init file required?
    if length(m.init_file) > 0 && isfile(m.init_file[id])
      cmd = `$cmd init=$(m.init_file[id])`
    else
      cmd = :init in keys(kwargs) ? `$cmd init=$(m.init_bound)` : `$cmd`
    end
    
    cmd = :seed in keys(kwargs) ? `$cmd random seed=$(m.seed)` : `$cmd`

    # Output files
    cmd = `$cmd output`

    if length(m.sample_file[id]) > 0
      cmd = `$cmd file=$(m.sample_file[id])`
    end

    if length(m.diagnostic_file) > 0
      cmd = `$cmd diagnostic_file=$(m.diagnostic_file[id])`
    end

    cmd = :save_cmdstan_config in keys(kwargs) ? `$cmd save_cmdstan_config=$(m.save_cmdstan_config)` : `$cmd`
    cmd = :sig_figs in keys(kwargs) ? `$cmd sig_figs=$(m.sig_figs)` : `$cmd`
    cmd = :refresh in keys(kwargs) ? `$cmd refresh=$(m.refresh)` : `$cmd`
      
    cmd
  end


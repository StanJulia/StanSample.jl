"""

Construct command line for chain id.

$(SIGNATURES)

### Required arguments
```julia
* `m::CmdStanSampleModel`              : CmdStanSampleModel
* `id::Int`                            : Chain id
``` 
Not exported
"""
function cmdline(m::SampleModel, id)
  
    #= cmdline with default parameter values
        `./bernoulli3 sample
        num_samples=1000 num_warmup=1000 save_warmup=0
        thin=1
        adapt engaged=1 gamma=0.05 delta=0.8 kappa=0.75 
        t0=10.0 init_buffer=75 term_buffer=50 window=25
        algorithm=hmc engine=nuts 
        max_depth=10 metric=diag_e stepsize=1.0 stepsize_jitter=1.0
        random seed=-1 
        init=bernoulli3_1.init.R 
        id=1 
        data file=bernoulli3_1.data.R 
        output file=bernoulli3_samples_1.csv
        refresh=100`
    =#

    cmd = ``
    # Handle the model name field for unix and windows
    cmd = `$(m.exec_path)`

    # Sample specific portion of the model
    cmd = `$cmd sample`
    
    #cmd = `$cmd num_threads=$(m.num_threads)`
    cmd = `$cmd num_samples=$(m.num_samples) num_warmup=$(m.num_warmups)`
    
    if m.save_warmup
        cmd = `$cmd save_warmup=1`
    else
        cmd = `$cmd save_warmup=0`
    end

    # Common to all models
    cmd = `$cmd thin=$(m.thin)`

    # Adapt section
    if m.engaged
        cmd = `$cmd adapt engaged=1`
    else
        cmd = `$cmd adapt engaged=0`
    end
    cmd = `$cmd gamma=$(m.gamma) delta=$(m.delta) kappa=$(m.kappa)`
    cmd = `$cmd t0=$(m.t0) init_buffer=$(m.init_buffer)`
    cmd = `$cmd term_buffer=$(m.init_buffer) window=$(m.window)`

    # Algorithm section
    cmd = `$cmd algorithm=$(string(m.algorithm)) engine=$(string(m.engine))`
    if m.engine == :nuts
        cmd = `$cmd max_depth=$(m.max_depth)`
    elseif m.engine == :static
        cmd = `$cmd int_time=$(m.int_time)`
    end
    cmd = `$cmd metric=$(string(m.metric)) stepsize=$(m.stepsize)`
    cmd = `$cmd stepsize_jitter=$(m.stepsize_jitter)`

    cmd = `$cmd random seed=$(m.seed)`

    # Init file required?
    if length(m.init_file) > 0 && isfile(m.init_file[id])
      cmd = `$cmd init=$(m.init_file[id])`
    else
      cmd = `$cmd init=$(m.init_bound)`
    end

    # Data file required?
    if length(m.data_file) > 0 && isfile(m.data_file[id])
      cmd = `$cmd id=$(id) data file=$(m.data_file[id])`
    end

    # Output files
    cmd = `$cmd output`
    if length(m.sample_file[id]) > 0
      cmd = `$cmd file=$(m.sample_file[id])`
    end
    if length(m.diagnostic_file) > 0
      cmd = `$cmd diagnostic_file=$(m.diagnostic_file[id])`
    end

    # Refresh rate
    cmd = `$cmd refresh=$(m.refresh)`
      
    cmd
  end


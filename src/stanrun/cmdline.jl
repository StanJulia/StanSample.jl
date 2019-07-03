"""

# cmdline 

Recursively parse the model to construct command line. 

### Method
```julia
cmdline(m)
```

### Required arguments
```julia
* `m::CmdStanSampleModel`                : CmdStanSampleModel
```

### Related help
```julia
?CmdStanSampleModel                      : Create a CmdStanSampleModel
```
"""
function cmdline(m, id)
  
  #=
  `./bernoulli3 sample num_samples=1000 num_warmup=1000 
    save_warmup=0 thin=1 adapt engaged=1 gamma=0.05 delta=0.8 kappa=0.75 
    t0=10.0 init_buffer=75 term_buffer=50 window=25 algorithm=hmc engine=nuts 
    max_depth=10 metric=diag_e stepsize=1.0 stepsize_jitter=1.0 random 
    seed=-1 init=bernoulli3_1.init.R id=1 data file=bernoulli3_1.data.R 
    output file=bernoulli3_samples_1.csv refresh=100`,
  =#
  cmd = ``
  if isa(m, CmdStanSampleModel)
    # Handle the model name field for unix and windows
    cmd = `$(m.exec_path)`

    # Sample() specific portion of the model
    cmd = `$cmd $(cmdline(getfield(m, :method), id))`
    
    # Common to all models
    cmd = `$cmd $(cmdline(getfield(m, :random), id))`
    
    # Init file required?
    if length(m.init_file) > 0 && isfile(m.init_file[id])
      cmd = `$cmd init=$(m.init_file[id])`
    else
      cmd = `$cmd init=$(m.init.bound)`
    end
    
    # Data file required?
    if length(m.data_file) > 0 && isfile(m.data_file[id])
      cmd = `$cmd id=$(id) data file=$(m.data_file[id])`
    end
    
    # Output options
    cmd = `$cmd output`
    if length(getfield(m, :output).file) > 0
      cmd = `$cmd file=$(string(getfield(m, :output).file))`
    end
    if length(m.diagnostic_file) > 0
      cmd = `$cmd diagnostic_file=$(string(getfield(m, :output).diagnostic_file))`
    end
    cmd = `$cmd refresh=$(string(getfield(m, :output).refresh))`
    
  else
    
    # The 'recursive' part
    if isa(m, SamplingAlgorithm)
      cmd = `$cmd algorithm=$(split(lowercase(string(typeof(m))), '.')[end])`
    elseif isa(m, Engine)
      cmd = `$cmd engine=$(split(lowercase(string(typeof(m))), '.')[end])`
    else
      cmd = `$cmd $(split(lowercase(string(typeof(m))), '.')[end])`
    end
    for name in fieldnames(typeof(m))
      if  isa(getfield(m, name), String) || isa(getfield(m, name), Tuple)
        cmd = `$cmd $(name)=$(getfield(m, name))`
      elseif length(fieldnames(typeof(getfield(m, name)))) == 0
        if isa(getfield(m, name), Bool)
          cmd = `$cmd $(name)=$(getfield(m, name) ? 1 : 0)`
        else
          if name == :metric || isa(getfield(m, name), DataType)
            cmd = `$cmd $(name)=$(split(lowercase(string(typeof(getfield(m, name)))), '.')[end])`
          else
            if name == :algorithm && typeof(getfield(m, name)) == CmdStan.Fixed_param
              cmd = `$cmd $(name)=fixed_param`
            else
              cmd = `$cmd $(name)=$(getfield(m, name))`
            end
          end
        end
      else
        cmd = `$cmd $(cmdline(getfield(m, name), id))`
      end
    end
  end
  
  cmd
  
end


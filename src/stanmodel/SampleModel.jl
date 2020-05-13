import Base: show

mutable struct SampleModel <: CmdStanModels
  @shared_fields_stanmodels
  method::Sample
end

"""

Create a SampleModel

$(SIGNATURES)

# Extended help

### Required arguments
```julia
* `name::AbstractString`               : Name for the model
* `model::AbstractString`              : Stan model source
```

### Optional arguments
```julia
* `n_chains::Vector{Int64}=[4]`        : Optionally updated in stan_sample()
* `seed::RandomSeed`                   : Random seed settings
* `init::Init`                         : Interval bound for parameters
* `output::Output`                     : File output options
* `tmpdir::AbstractString`             : Directory where output files are stored
* `output_base::AbstractString`        : Base name for output files
* `exec_path::AbstractString`          : Path to cmdstan executable
* `data_file::vector{AbstractString}`  : Path to per chain data file
* `init_file::Vector{AbstractString}`  : Path to per chain init file
* `sample_file::Vector{String}         : Path to per chain samples file
* `cmds::Vector{Cmd}`                  : Path to per chain init file
* `log_file::Vector{String}            : Path to per chain log file
* `diagnostic_file::Vector{String}     : Path to per chain diagnostic file
* `summary=true`                       : Create computed stan summary
* `method::Sample                      : Will be Sample()  
```
"""
function SampleModel(
  name::AbstractString,
  model::AbstractString,
  n_chains=[4];
  seed = StanBase.RandomSeed(),
  init = StanBase.Init(),
  output = StanBase.Output(),
  tmpdir = mktempdir(),
  method = Sample(),
)
  
  !isdir(tmpdir) && mkdir(tmpdir)
  
  StanBase.update_model_file(joinpath(tmpdir, "$(name).stan"), strip(model))
  
  output_base = joinpath(tmpdir, name)
  exec_path = output_base
  cmdstan_home = get_cmdstan_home()

  error_output = IOBuffer()
  is_ok = cd(cmdstan_home) do
      success(pipeline(`make -f $(cmdstan_home)/makefile -C $(cmdstan_home) $(exec_path)`;
                       stderr = error_output))
  end
  if !is_ok
      throw(StanModelError(name, String(take!(error_output))))
  end

  SampleModel(name, model, n_chains, seed, init, output,
    tmpdir, output_base, exec_path, String[], String[], 
    Cmd[], String[], String[], String[], false, false,
    cmdstan_home, method)
end

function Base.show(io::IO, ::MIME"text/plain", m::SampleModel)
  println(io, "  name =                    \"$(m.name)\"")
  println(io, "  n_chains =                $(StanBase.get_n_chains(m))")
  println(io, "  output =                  Output()")
  println(io, "    refresh =                 $(m.output.refresh)")
  println(io, "  tmpdir =                  \"$(m.tmpdir)\"")
  println(io, "  method =                  Sample()")
  println(io, "    num_samples =             ", m.method.num_samples)
  println(io, "    num_warmup =              ", m.method.num_warmup)
  println(io, "    save_warmup =             ", m.method.save_warmup)
  println(io, "    thin =                    ", m.method.thin)
  if isa(m.method.algorithm, Hmc)
    println(io, "    algorithm =               HMC()")
    if isa(m.method.algorithm.engine, Nuts)
      println(io, "      engine =                  NUTS()")
      println(io, "        max_depth =               ", m.method.algorithm.engine.max_depth)
    elseif isa(m.method.algorithm.engine, Static)
      println(io, "      engine =                  Static()")
      println(io, "        int_time =                ", m.method.algorithm.engine.int_time)
    end
    println(io, "      metric =                  ", typeof(m.method.algorithm.metric))
    println(io, "      stepsize =                ", m.method.algorithm.stepsize)
    println(io, "      stepsize_jitter =         ", m.method.algorithm.stepsize_jitter)
  else
    if isa(m.method.algorithm, Fixed_param)
      println(io, "    algorithm =               Fixed_param()")
    else
      println(io, "    algorithm =               Unknown")
    end
  end
  println(io, "    adapt =                   Adapt()")
  println(io, "      gamma =                   ", m.method.adapt.gamma)
  println(io, "      delta =                   ", m.method.adapt.delta)
  println(io, "      kappa =                   ", m.method.adapt.kappa)
  println(io, "      t0 =                      ", m.method.adapt.t0)
  println(io, "      init_buffer =             ", m.method.adapt.init_buffer)
  println(io, "      term_buffer =             ", m.method.adapt.term_buffer)
  println(io, "      window =                  ", m.method.adapt.window)
end

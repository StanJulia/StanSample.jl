import Base: show

"""
# SampleModel 

Create a SampleModel. 

### Required arguments
```julia
* `name::AbstractString`        : Name for the model
* `model::AbstractString`       : Stan model source
```

### Optional arguments
```julia
* `n_chains::Vector{Int64}=[4]`        : Optionally updated in stan_sample()
* `seed::RandomSeed`                   : Random seed settings
* `output::Output`              : File output options
* `init::Init`                         : Default interval bound for parameters
* `tmpdir::AbstractString`             : Directory where output files are stored
* `output_base::AbstractString`        : Base name for output files
* `exec_path::AbstractString`          : Path to cmdstan executable
* `data_file::vector{AbstractString}`  : Path to per chain data file
* `init_file::Vector{AbstractString}`  : Path to per chain init file
* `cmds::Vector{Cmd}`                  : Path to per chain init file
* `sample_file::Vector{String}         : Path to per chain samples file
* `log_file::Vector{String}            : Path to per chain log file
* `diagnostic_file::Vector{String}    : Path to per chain diagnostic file
* `summary=true`                       : Create computed stan summary
* `printsummary=true`                  : Show computed stan summary
* `sm::StanRun.StanModel`              : StanRun.StanModel
* `method::Sample                         : Will be Sample()  
```

"""
mutable struct SampleModel <: CmdStanModels
  @shared_fields_stanmodels
  method::Sample
end

function SampleModel(
  name::AbstractString,
  model::AbstractString,
  n_chains=[4];
  method = Sample(),
  seed = StanBase.RandomSeed(),
  init = StanBase.Init(),
  output = StanBase.Output(),
  tmpdir = mktempdir())
  
  !isdir(tmpdir) && mkdir(tmpdir)
  
  StanBase.update_model_file(joinpath(tmpdir, "$(name).stan"), strip(model))
  sm = StanModel(joinpath(tmpdir, "$(name).stan"))
  
  output_base = StanRun.default_output_base(sm)
  exec_path = StanRun.ensure_executable(sm)
  
  stan_compile(sm)
  
  SampleModel(name, model, n_chains, seed, init, output,
    tmpdir, output_base, exec_path, String[], String[], 
    Cmd[], String[], String[], String[], false, false, sm, method)
end

function Base.show(io::IO, ::MIME"text/plain", m::SampleModel)
  println(io, "  name =                    \"$(m.name)\"")
  println(io, "  n_chains =                $(StanBase.get_n_chains(m))")
  println(io, "  output =                  Output()")
  println(io, "    file =                    \"$(split(m.output.file, "/")[end])\"")
  println(io, "    diagnostics_file =        \"$(split(m.output.diagnostic_file, "/")[end])\"")
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

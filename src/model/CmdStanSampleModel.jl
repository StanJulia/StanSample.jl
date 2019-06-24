import Base: show

"""
# CmdStanSampleModel 

Create a CmdStanSampleModel. 

### Required arguments
```julia
* `name::AbstractString`        : Name for the model
* `model::AbstractString`       : Stan model source
```

### Optional arguments
```julia
* `method::AbstractStanMethod`  : See ?Method (default: Sample())
* `random::Random`              : Random seed settings
* `output::Output`              : File output options
* `tmpdir::AbstractString`      : Directory where output files are stored
* `summary=true`                : Create computed stan summary
* `printsummary=true`           : Show computed stan summary
```

"""
mutable struct CmdStanSampleModel
  name::AbstractString
  model::AbstractString
  method::Method
  random::Random
  output::Output
  tmpdir::AbstractString
  summary::Bool
  printsummary::Bool
  sm::StanRun.StanModel
end

function CmdStanSampleModel(
  name::AbstractString,
  model::AbstractString;
  method = Sampler(),
  random = Random(),
  output = Output(),
  tmpdir = mktempdir())
  
  !isdir(tmpdir) && mkdir(tmpdir)
  
  update_model_file(joinpath(tmpdir, "$(name).stan"), strip(model))
  sm = StanModel(joinpath(tmpdir, "$(name).stan"))
  
  output.output_base = default_output_base(sm)
  
  stan_compile(sm)
  
  CmdStanSampleModel(name, model, method, random, output, tmpdir, false, false, sm)
end

function model_show(io::IO, m::CmdStanSampleModel, compact::Bool)
  println("  name =                    \"$(m.name)\"")
  println("  model_file =              \"$(m.model_file)\"")
  println("  output =                  Output()")
  println("    file =                    \"$(m.output.file)\"")
  println("    diagnostics_file =        \"$(m.output.diagnostic_file)\"")
  println("    refresh =                 $(m.output.refresh)")
  println("  tmpdir =                 \"$(m.tmpdir)\"")
  if isa(m.method, Sample)
    sample_show(io, m.method, compact)
  elseif isa(m.method, Optimize)
    optimize_show(io, m.method, compact)
  elseif isa(m.method, Variational)
    variational_show(io, m.method, compact)
  else
    diagnose_show(io, m.method, compact)
  end
end

show(io::IO, m::CmdStanSampleModel) = model_show(io, m, false)

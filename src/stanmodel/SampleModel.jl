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

function model_show(io::IO, m::SampleModel, compact::Bool)
  println("  name =                    \"$(m.name)\"")
  println("  n_chains =                $(StanBase.get_n_chains(m))")
  println("  output =                  Output()")
  println("    file =                    \"$(split(m.output.file, "/")[end])\"")
  println("    diagnostics_file =        \"$(split(m.output.diagnostic_file, "/")[end])\"")
  println("    refresh =                 $(m.output.refresh)")
  println("  tmpdir =                  \"$(m.tmpdir)\"")
  sample_show(io, m.method, compact)
end

show(io::IO, m::SampleModel) = model_show(io, m, false)

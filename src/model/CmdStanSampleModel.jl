mutable struct CmdStanSampleModel
  name::AbstractString
  model::AbstractString
  num_chains::Int
  num_warmup::Int
  num_samples::Int
  thin::Int
  id::Int
  model::String
  model_file::String
  monitors::Vector{String}
  data::Vector{DataDict}
  data_file::String
  command::Vector{Base.AbstractCmd}
  method::Method
  random::Random
  init::Vector{DataDict}
  init_file::String
  output::Output
  output_base::AbstractString
  printsummary::Bool
  sm::StanRun.StanModel
  pdir::String
  tmpdir::AbstractString
  output_format::Symbol
  settings::StanSample.SamplerSettings
end

function CmdStanSampleModel(name::AbstractString, model::AbstractString;
  tmpdir = mktempdir(), 
  settings = StanSample.sampler_settings)
  
  !isdir(tmpdir) && mkdir(tmpdir)
  update_model_file(joinpath(tmpdir, "$(name).stan"), strip(model))
  sm = StanModel(joinpath(tmpdir, "$(name).stan"))
  output_base = default_output_base(sm)
  stan_compile(sm)
  CmdStanSampleModel(name, model, tmpdir, output_base, sm, settings)
end

function Base.show(io::IO, model::CmdStanSampleModel)
    @unpack tmpdir, sm = model
    println(io, "Stan model at `$(tmpdir)`")
    println("`cmdstan` executable is at: $(sm.cmdstan_home))")
end


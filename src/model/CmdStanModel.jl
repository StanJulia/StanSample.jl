struct CmdStanModel
  name::AbstractString
  model::AbstractString
  tmpdir::AbstractString
  sm::StanRun.StanModel
  settings::StanSample.SamplerSettings
end

function CmdStanModel(name::AbstractString, model::AbstractString;
  tmpdir = mktempdir(), 
  settings = StanSample.sampler_settings)
  
  !isdir(tmpdir) && mkdir(tmpdir)
  update_model_file(joinpath(tmpdir, "$(name).stan"), strip(model))
  sm = StanModel(joinpath(tmpdir, "$(name).stan"))
  CmdStanModel(name, model, tmpdir, sm, settings)
end

function Base.show(io::IO, model::CmdStanModel)
    @unpack name, model, tmpdir, sm, settings = model
    println(io, "Stan model at `$(tmpdir)`")
    println("`cmdstan` executable is at: $(sm.cmdstan_home))")
end


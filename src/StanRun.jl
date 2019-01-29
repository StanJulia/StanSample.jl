module StanRun

export StanModel, stan_sample

using ArgCheck: @argcheck
using DocStringExtensions: SIGNATURES
using Parameters: @unpack
using StanDump: stan_dump

const CMDSTAN_HOME_VAR = "JULIA_CMDSTAN_HOME"

function get_cmdstan_home()
    get(ENV, CMDSTAN_HOME_VAR) do
        throw(ArgumentError("The environment variable $CMDSTAN_HOME_VAR needs to be set."))
    end
end

struct StanModel{S <: AbstractString}
    source_path::S
    cmdstan_home::S
end

"""
$(SIGNATURES)

Replace the extension of `path` (including the `'.'`) with `new_ext`, which can be any
string (not necessarily an extension, with the dot).

When `verified_ext` is given, it the original extension is checked to be equivalent.
Defaults to `".stan"`.
"""
function replace_ext(path::AbstractString, new_ext, verified_ext = ".stan")
    basename, ext = splitext(path)
    verified_ext ≢ nothing && @argcheck ext == verified_ext
    basename * new_ext
end

"""
$(SIGNATURES)

Executable path corresponding to a source file, or a model.
"""
function executable_path(source_path::AbstractString)
    replace_ext(source_path, Sys.iswindows() ? ".exe" : "")
end

executable_path(model::StanModel) = executable_path(model.source_path)

function StanModel(source_path; cmdstan_home = get_cmdstan_home())
    StanModel(source_path, cmdstan_home)
end

function ensure_executable(model::StanModel)
    @unpack cmdstan_home = model
    exec_path = executable_path(model)
    cd(cmdstan_home) do
        run(`make -f $(cmdstan_home)/makefile -C $(cmdstan_home) $(exec_path)`)
    end
    exec_path
end

default_output_base(model::StanModel) = replace_ext(model.source_path, "", ".stan")

function stan_sample(model::StanModel, data, n_chains;
                     output_base = default_output_base(model),
                     data_file = output_base * ".data.R",
                     rm_samples = true)
    exec_path = ensure_executable(model)
    stan_dump(data_file, data; force = true)
    sample_files = [output_base * "_chain_$(i).csv" for i in 1:n_chains]
    rm_samples && rm.(find_samples(model))
    for (i, sample_file) in enumerate(sample_files)
        run(`$(exec_path) sample id=$(i) data file=$(data_file) output file=$(sample_file)`)
    end
    sample_files
end

"""
$(SIGNATURES)

Return filenames of CSV files (with MCMC samples, this is not checked) matching
`output_base` from the model.
"""
function find_samples(output_base::AbstractString)
    dir, basename = splitdir(output_base)
    rx = Regex(basename * raw"_chain_\d+.csv")
    joinpath.(Ref(dir), filter(file -> occursin(rx, file), readdir(dir)))
end

find_samples(model::StanModel) = find_samples(default_output_base(model))

end # module

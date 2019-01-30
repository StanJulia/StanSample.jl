"""
Helper infrastructure to compile and sample models using `cmdstan`.

[`StanModel`](@ref) wraps a model definition (source code), while [`stan_sample`](@ref) can
be used to sample from it.
"""
module StanRun

export StanModel, stan_sample

using ArgCheck: @argcheck
using Distributed: pmap
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

Internal, not exported.
"""
function replace_ext(path::AbstractString, new_ext, verified_ext = ".stan")
    basename, ext = splitext(path)
    verified_ext ≢ nothing && @argcheck ext == verified_ext
    basename * new_ext
end

"""
$(SIGNATURES)

Executable path corresponding to a source file, or a model.

Internal, not exported.
"""
function executable_path(source_path::AbstractString)
    replace_ext(source_path, Sys.iswindows() ? ".exe" : "")
end

executable_path(model::StanModel) = executable_path(model.source_path)

"""
$(SIGNATURES)

Define a model by its Stan source code location, which needs to end in `".stan"`.

Its directory needs to be *writable*, as it will contain the compiled executable (generated
on demand if it does not exist, or if the source code is more recent).

`cmdstan_home` should specify the directory of the `cmdstan` installation. The default is
obtained from the environment variable `$(CMDSTAN_HOME_VAR)`."
"""
function StanModel(source_path; cmdstan_home = get_cmdstan_home())
    StanModel(source_path, cmdstan_home)
end

"""
$(SIGNATURES)

Ensure that a compiled model executable exists, and return its path.

Internal, not exported.
"""
function ensure_executable(model::StanModel)
    @unpack cmdstan_home = model
    exec_path = executable_path(model)
    cd(cmdstan_home) do
        run(`make -f $(cmdstan_home)/makefile -C $(cmdstan_home) $(exec_path)`)
    end
    exec_path
end

"""
$(SIGNATURES)

Default `output_base`, in the same directory as the model. Internal, not exported.
"""
default_output_base(model::StanModel) = replace_ext(model.source_path, "", ".stan")

sample_file_path(output_base::AbstractString, id::Int) = output_base * "_chain_$(id).csv"

log_file_path(output_base::AbstractString, id::Int) = output_base * "_chain_$(id).log"

"""
$(SIGNATURES)

Make a Stan command. Internal, not exported.
"""
function stan_cmd_and_paths(exec_path::AbstractString, data_file::AbstractString,
                            output_base::AbstractString, id::Integer)
    sample_file = sample_file_path(output_base, id)
    log_file = log_file_path(output_base, id)
    pipeline(`$(exec_path) sample id=$(id) data file=$(data_file) output file=$(sample_file)`;
             stdout = log_file), (sample_file, log_file)
end

"""
$(SIGNATURES)

Sample `n_chains` from `model` using `data`. Return the full paths of the sample files.

`output_base` is used to write the data file (using `StanDump.stan_dump`) and to determine
the resulting names for the sampler output. It defaults to the source file name without the
extension.

When `rm_samples` (default: `true`), remove potential pre-existing sample files after
compiling the model.
"""
function stan_sample(model::StanModel, data, n_chains;
                     output_base = default_output_base(model),
                     data_file = output_base * ".data.R",
                     rm_samples = true)
    exec_path = ensure_executable(model)
    stan_dump(data_file, data; force = true)
    rm_samples && rm.(find_samples(model))
    cmds_and_paths = [stan_cmd_and_paths(exec_path, data_file, output_base, id)
                      for id in 1:n_chains]
    pmap(cmds_and_paths) do cmd_and_path
        run(first(cmd_and_path))
        last(cmd_and_path)
    end
end

"""
$(SIGNATURES)

Return filenames of CSV files (with MCMC samples, this is not checked) matching
`output_base` from the model.

Part of the API, but not exported.
"""
function find_samples(output_base::AbstractString)
    dir, basename = splitdir(output_base)
    rx = Regex(basename * raw"_chain_\d+.csv")
    joinpath.(Ref(dir), filter(file -> occursin(rx, file), readdir(dir)))
end

find_samples(model::StanModel) = find_samples(default_output_base(model))

end # module

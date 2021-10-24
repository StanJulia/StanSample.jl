"""

Executable path corresponding to a source file, or a model.

$(SIGNATURES)

# Extended help

Internal, not exported.
"""
function executable_path(source_path::AbstractString)
    if Sys.iswindows()
        source_path =  source_path * ".exe"
    end
    source_path = source_path
end

executable_path(model::T) where T <: CmdStanModels =
    executable_path(model.tmpdir)

"""

Error thrown when a Stan model fails to compile. 

$(TYPEDEF)

# Extended help

Accessing fields directly is part of the API.

$(FIELDS)
"""
struct StanModelError <: Exception
    name::String
    message::String
end

function Base.showerror(io::IO, e::StanModelError)
    print(io, "\nError when compiling SampleModel ", e.name, ":\n",
          e.message)
end

"""

Ensure that a compiled model executable exists, and return its path.

$(SIGNATURES)

# Extended help

If compilation fails, a `StanModelError` is returned instead.

Internal, not exported.
"""
function ensure_executable(model::T) where T <: CmdStanModels
    @unpack cmdstan_home, exec_path = model
    error_output = IOBuffer()
    is_ok = cd(cmdstan_home) do
        success(pipeline(`make -f $(cmdstan_home)/makefile -C $(cmdstan_home) $(exec_path)`;
                         stderr = error_output))
    end
    if is_ok
        exec_path
    else
        throw(StanModelError(model.name, String(take!(error_output))))
    end
end

"""

Compile a model, throwing an error if it failed.

$(SIGNATURES)
"""
function stan_compile(model::T) where T <: CmdStanModels
    ensure_executable(model)
    nothing
end


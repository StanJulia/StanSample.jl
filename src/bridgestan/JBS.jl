#module JBS

mutable struct StanModelStruct
end

mutable struct StanModel
    lib::Ptr{Nothing}
    stanmodel::Ptr{StanModelStruct}
    dims::Int
    data::String
    seed::UInt32
    log_density::Vector{Float64}
    gradient::Vector{Float64}
    function StanModel(stanlib_::Ptr{Nothing}, datafile_::String, seed_ = 204)
        seed = convert(UInt32, seed_)

        stanmodel = ccall(Libc.Libdl.dlsym(stanlib_, "create"),
                          Ptr{StanModelStruct},
                          (Cstring, UInt32),
                          datafile_, seed)

        dims = ccall(Libc.Libdl.dlsym(stanlib_, "get_num_unc_params"),
                  Cint,
                  (Ptr{Cvoid},),
                  stanmodel)

        sm = new(stanlib_, stanmodel, dims, datafile_, seed, zeros(1), zeros(dims))

        function f(sm)
            ccall(Libc.Libdl.dlsym(sm.lib, "destroy"),
                  Cvoid,
                  (Ptr{Cvoid},),
                  sm.stanmodel)
        end

        finalizer(f, sm)
    end
end

function log_density_gradient!(sm::StanModel, q; propto = 1, jacobian = 1)
    ccall(Libc.Libdl.dlsym(sm.lib, "log_density_gradient"),
          Cvoid,
          (Ptr{StanModelStruct}, Cint, Ref{Cdouble}, Ref{Cdouble}, Ref{Cdouble}, Cint, Cint),
          sm.stanmodel, sm.dims, q, sm.log_density, sm.gradient, propto, jacobian)
end

function destroy(sm::StanModel)
    ccall(Libc.Libdl.dlsym(sm.lib, "destroy"),
          Cvoid,
          (Ptr{StanModelStruct},),
          sm.stanmodel)
end

"""

Error thrown when a BridgeStan shared library fails to compile. 

$(TYPEDEF)

# Extended help

Accessing fields directly is part of the API.

$(FIELDS)
"""
struct BridgeStanError <: Exception
    name::String
    message::String
end

function Base.showerror(io::IO, e::BridgeStanError)
    print(io, "\nError when compiling BridgeStan shared library ", e.name, ":\n",
          e.message)
end



export
    StanModel,
    log_density_gradient!,
    destroy,
    BridgeStanError

#end

module BridgeStanExt

using StanSample, DocStringExtensions

StanSample.EXTENSIONS_SUPPORTED ? (using BridgeStan) : (using ..BridgeStan)

const BS = BridgeStan
const BRIDGESTAN_PATH = get_bridgestan_path()
println(BRIDGESTAN_PATH)
BS.set_bridgestan_path!(BRIDGESTAN_PATH)
export BS, BRIDGESTAN_HOME, StanModel


"""

Create a BridgeStan shared object.

$(SIGNATURES)

### Required positional arguments
```julia
* `sm::SampleModel`                    : SampleModel
``` 

### Optional positional arguments
```julia
* `data_file=joinpath(sm.tmpdir, sm.name * "_data_1.json")`
```

### Returns

Valid BridgeStan StanModel object or nothing
if either the shared object or data file is missing.


Exported
"""
function StanSample.create_smb(sm::SampleModel, 
    data_file=joinpath(sm.tmpdir, sm.name * "_data_1.json"))

    if !isfile(data_file)
        @info "File `$(data_file)` not found."
        return nothing
    end

    smb = BridgeStan.StanModel(;
        stan_file = joinpath(sm.tmpdir, sm.name*".stan"),
        stanc_args=["--warn-pedantic --O1"],
        make_args=["CXX=clang++", "STAN_THREADS=true"],
        data = data_file
    )

    if !isfile(joinpath(sm.tmpdir, sm.name) * "_model.so")
        @info "Shared library $(joinpath(sm.tmpdir, sm.name))_model.so has not been created."
        @info "Maybe BridgeStan has not been installed?"
        return nothing
    end

    smb
end

end

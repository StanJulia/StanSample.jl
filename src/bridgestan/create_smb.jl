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
function create_smb(sm::SampleModel, 
    data_file=joinpath(sm.tmpdir, sm.name * "_data_1.json"))

    lib = joinpath(sm.tmpdir, sm.name * "_model.so")
    if !isfile(data_file)
        @info "File `$(data_file)` not found."
        return nothing
    end
    if isfile(lib)
        smb = bridgestan.StanModel(lib, data_file)
    else
        @info "Shared library `$(sm.name)_model.so` has not been created."
        @info "Maybe BridgeStan has not been installed in $(ENV["CMDSTAN"])?"
        return nothing
    end
    smb
end

export
    create_smb
"""
Helper infrastructure to compile and sample models using `cmdstan`.

[`StanModel`](@ref) wraps a model definition (source code), while [`stan_sample`](@ref) can
be used to sample from it.

[`stan_compile`](@ref) can be used to pre-compile a model without sampling. A
[`StanModelError`](@ref) is thrown if this fails, which contains the error messages from
`stanc`.
"""
module StanSample

using Reexport

@reexport using StanBase

using DocStringExtensions: FIELDS, SIGNATURES, TYPEDEF

import StanRun: stan_sample, stan_cmd_and_paths, default_output_base
import StanSamples: read_samples
import StanBase: cmdline

include("stanmodel/sample_types.jl")
include("stanmodel/SampleModel.jl")
include("stanrun/cmdline.jl")
include("stanrun/stan_generate_quantities.jl")
include("stansamples/read_samples.jl")

export
  SampleModel,
  stan_generate_quantities

end # module

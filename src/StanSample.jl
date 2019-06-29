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

@reexport using Unicode, DelimitedFiles, Distributed, OrderedCollections
@reexport using StanDump
@reexport using StanRun
@reexport using StanSamples
@reexport using MCMCChains
@reexport using Parameters

using DocStringExtensions: FIELDS, SIGNATURES, TYPEDEF
using CmdStan: update_model_file, convert_a3d

import StanRun: stan_cmd_and_paths, default_output_base
import StanRun: stan_sample

include("utilities/sample_types.jl")
include("model/CmdStanSampleModel.jl")
#include("utilities/create_R_data_files.jl")
#include("utilities/create_R_init_files.jl")
include("utilities/read_stanrun_samples.jl")
include("utilities/cmdline.jl")
include("utilities/stan_sample.jl")
include("utilities/stan_cmd_and_paths.jl")

export  CmdStanSampleModel,
  Sample, Adapt,
  cmdline,
  read_stanrun_samples, update_settings,
  update_model_file, convert_a3d, data_file_path,
  default_output_base, create_R_data_files

end # module

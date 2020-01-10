"""
$(SIGNATURES)

Helper infrastructure to compile and sample models using `cmdstan`.
"""
module StanSample

using StanBase
using DocStringExtensions: FIELDS, SIGNATURES, TYPEDEF

import StanBase: stan_sample, get_cmdstan_home
import StanBase: cmdline, read_summary, stan_summary

include("stanmodel/sample_types.jl")
include("stanmodel/SampleModel.jl")
include("stanrun/cmdline.jl")
include("stanrun/stan_generate_quantities.jl")
include("stansamples/read_samples.jl")

export
  SampleModel,
  stan_sample,
  read_samples,
  read_summary,
  stan_summary,
  stan_generate_quantities

end # module
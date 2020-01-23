"""
$(SIGNATURES)

Helper infrastructure to compile and sample models using `cmdstan`.
"""
module StanSample

using StanBase, StanSamples

using Requires
using DocStringExtensions: FIELDS, SIGNATURES, TYPEDEF

import StanBase: stan_sample, get_cmdstan_home
import StanBase: cmdline, read_summary, stan_summary
import StanBase: RandomSeed, Init, Output, StanModelError

function __init__()
  @require MCMCChains="c7f686f2-ff18-58e9-bc7b-31028e88f75d" include("stansamples/require_mcmcchains.jl")
end

include("stanmodel/sample_types.jl")
include("stanmodel/SampleModel.jl")
include("stanrun/cmdline.jl")
include("stanrun/stan_generated_quantities.jl")
include("stansamples/read_samples.jl")
include("stansamples/convert_a3d.jl")
include("stansamples/read_generated_quantities.jl")

export
  SampleModel,
  StanModelError,
  stan_sample,
  read_samples,
  read_summary,
  stan_summary,
  stan_generate_quantities,
  read_generated_quantities

end # module
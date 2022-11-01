using InferenceObjects
using PosteriorDB

import Base: convert

"""

# inference

# Convert the output file(s) created by cmdstan to a InferenceData object.

$(SIGNATURES)

"""
function convert(m::SampleModel, ::Val{:inferencedata})
    stan_nts = read_samples(m, :namedtuples; include_internals=true)
end

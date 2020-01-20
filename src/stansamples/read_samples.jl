import StanSamples: read_samples

# read_samples

"""

Read sample output files created by StanSample.jl.

$(SIGNATURES)

### Required arguments
```julia
* `model`                    : SampleModel
```

"""
function read_samples(model::SampleModel;  start=1)

  s1 = StanSamples.read_samples(model.output_base*"_chain_1.csv")
  sa = Vector{typeof(s1)}(undef, model.n_chains[1])
  sa[1] = s1
  if model.n_chains[1] > 1
    for i in 2:model.n_chains[1]
      sa[i] = StanSamples.read_samples(model.output_base*"_chain_$i.csv")
    end
  end

  sa

end   # end of read_samples

# read_generated_quantities

"""

Read generated_quantities output files created by StanSample.jl.

$(SIGNATURES)

### Required arguments
```julia
* `model`                    : SampleModel
```

"""
function read_generated_quantities(model::SampleModel)

  s1 = StanSamples.read_samples(model.output_base*"_generated_quantities_1.csv")
  sa = Vector{typeof(s1)}(undef, model.n_chains[1])
  sa[1] = s1
  if model.n_chains[1] > 1
    for i in 2:model.n_chains[1]
      if isfile(model.output_base*"_generated_quantities_$i.csv")
        sa[i] = StanSamples.read_samples(model.output_base*"_generated_quantities_$i.csv")
      end
    end
  end

  sa

end   # end of read_generated_quantities


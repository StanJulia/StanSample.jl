sample_defaults = OrderedDict(
  :num_samples => 1000,
  :num_warmup => 1000,
  :save_warmup => 0,
  :thin => 1
)

adapt_defaults = OrderedDict(
  :engaged => 1,
  :gamma => 0.05,
  :delta => 0.8,
  :kappa => 0.75,
  :t0 => 10.0,
  :init_buffer => 75,
  :term_buffer => 50,
  :window => 25,
  :algorithm => :hmc,
  :engine => :nuts,
  :max_depth => 10,
  :metric => :diag_e,
  :stepsize => 1.0,
  :stepsize_jitter => 1.0
)

random_defaults = OrderedDict(
  :seed => -1
)

refresh_defaults = OrderedDict(
  :refresh=> 100
)

struct SamplerSettings
  sample::OrderedDict
  adapt::OrderedDict
  random::OrderedDict
  refresh::OrderedDict
end

sampler_settings = SamplerSettings(sample_defaults, adapt_defaults,
  random_defaults, refresh_defaults)

function update_settings(s)
  for key in keys(s)
    if key in keys(sample_defaults)
      sample_defaults[key = values(s[key])]
      continue
    end
    if key in keys(adapt_defaults)
      adapt_defaults[key]= values(s[key])
      continue
    end
    if key in keys(random_defaults)
      random_defaults[key] = values(s[key])
      continue
    end
    if key in keys(refresh_defaults)
      refres_defaults[key] = values(s[key])
      continue
    end
    error("Improper setting name: $key")
  end
end
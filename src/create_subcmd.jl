function create_subcmd(s::SamplerSettings)
  subcmd  = `sample`
  for section in [s.sample, s.adapt, s.random]
    if section == s.adapt
      subcmd = `$subcmd adapt `
    end
    if section == s.random
      subcmd = `$subcmd random `
    end
    for key in keys(section)
      subcmd = `$subcmd $(string(key))=$(section[key])`
    end
  end
  subcmd
end
  
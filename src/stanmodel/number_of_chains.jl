function get_n_chains(model::CmdStanSampleModel)
  model.n_chains[1]
end

function set_n_chains(model::CmdStanSampleModel, n_chains)
  model.n_chains[1] = n_chains
end
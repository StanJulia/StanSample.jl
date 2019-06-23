using StanSample, Test

@testset "Create subcmd" begin
  include("../src/utilities/sample_types.jl")
  include("../src/utilities/create_cmd_line.jl")
end


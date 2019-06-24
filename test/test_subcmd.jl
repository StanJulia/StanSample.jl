using StanSample, Test

@testset "Create subcmd" begin
  ProjDir = @__DIR__
  cd(ProjDir) #do

    bernoulli_model = "
    data { 
      int<lower=1> N; 
      int<lower=0,upper=1> y[N];
    } 
    parameters {
      real<lower=0,upper=1> theta;
    } 
    model {
      theta ~ beta(1,1);
      y ~ bernoulli(theta);
    }
    ";

    bernoulli_data = [
      Dict("N" => 10, "y" => [0, 1, 0, 1, 0, 0, 0, 0, 0, 1]),
      Dict("N" => 10, "y" => [0, 1, 0, 0, 0, 0, 1, 0, 0, 1]),
      Dict("N" => 10, "y" => [0, 0, 0, 0, 0, 0, 1, 0, 1, 1]),
      Dict("N" => 10, "y" => [0, 0, 0, 1, 0, 0, 0, 1, 0, 1])
    ]
  
  cssm = CmdStanSampleModel("bernoulli", bernoulli_model)

end


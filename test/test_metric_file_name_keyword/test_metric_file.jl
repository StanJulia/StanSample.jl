######### StanSample Bernoulli example  ###########

using StanSample

bernoulli_model = "
data {
  int N;
  array[N] int y;
}
parameters {
  real<lower=0,upper=1> theta;
}
model {
  theta ~ beta(1,1);
  y ~ bernoulli(theta);
}
";

metric_file_name = "bernoulli.diag_e.json"


open(joinpath(tempdir(), metric_file_name), "w") do f
    write(f, "{ \"inv_metric\" : [0.296291] }")
end


data = Dict("N" => 10, "y" => [0, 1, 0, 1, 0, 0, 0, 0, 0, 1])
sm = SampleModel("bernoulli", bernoulli_model);

rc = stan_sample(
    sm;
    data,
    algorithm = :hmc,
    stepsize = 0.9,
    metric_file = joinpath(tempdir(), metric_file_name),
    num_warmups = 0,
    engaged = false,
);

if success(rc)
    (samples, cnames) = read_samples(sm, :array; return_parameters = true)
    @assert occursin(metric_file_name, string(rc.processes[1].cmd))
    sdf = read_summary(sm)
    sdf |> display
end

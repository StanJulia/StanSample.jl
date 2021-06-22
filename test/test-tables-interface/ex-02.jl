using StanSample, Random, Distributions, Test

begin
    N = 100
    df = DataFrame(
      :h0 => rand(Normal(10,2 ), N),
      :treatment => vcat(zeros(Int, Int(N/2)), ones(Int, Int(N/2)))
    );
    df[!, :fungus] =
        [rand(Binomial(1, 0.5 - 0.4 * df[i, :treatment]), 1)[1] for i in 1:N]
    df[!, :h1] =
        [df[i, :h0] + rand(Normal(5 - 3 * df[i, :fungus]), 1)[1] for i in 1:N]
    data = Dict(
        :N => nrow(df),
        :h0 => df[:, :h0],  
        :h1 => df[:, :h1],
        :fungus => df[:, :fungus],
        :treatment => df[:, :treatment]
    );
end;

stan6_7 = "
data {
  int <lower=1> N;
  vector[N] h0;
  vector[N] h1;
  vector[N] treatment;
  vector[N] fungus;
}
parameters{
  real a;
  real bt;
  real bf;
  real<lower=0> sigma;
}
model {
  vector[N] mu;
  vector[N] p;
  a ~ lognormal(0, 0.2);
  bt ~ normal(0, 0.5);
  bf ~ normal(0, 0.5);
  sigma ~ exponential(1);
  for ( i in 1:N ) {
    p[i] = a + bt*treatment[i] + bf*fungus[i];
    mu[i] = h0[i] * p[i];
  }
  h1 ~ normal(mu, sigma);
}
";

# ╔═╡ 655d0bcb-a4ab-41b4-8525-3e9f066113fd
begin
    m6_7s = SampleModel("m6.7s", stan6_7)
    rc6_7s = stan_sample(m6_7s; data)
end;

if success(rc6_7s)
    nt6_7s = read_samples(m6_7s)
    df6_7s = read_samples(m6_7s; output_format=:dataframe)
    a6_7s, cnames = read_samples(m6_7s; output_format=:array, return_parameters=true);
end

st = convert_a3d(a6_7s, cnames, Val(:table))

# Testing

@test Tables.istable(st) == true

rows = Tables.rows(st)
for row in rows
    rowvals = [Tables.getcolumn(row, col) for col in Tables.columnnames(st)]
end

@test length(Tables.getcolumn(rows, :a)) == 4000
cols = Tables.columns(st)

@test Tables.schema(rows) == Tables.schema(cols)

@test size(DataFrame(st)) == (4000, 4)

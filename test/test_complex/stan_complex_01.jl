using StanSample, JSON, DataFrames

stan = "
data {
  int<lower=0> N;
  array[N] complex x;
  array[N] complex y;
}
parameters {
  complex alpha;
  complex beta;
  vector[2] sigma;
}
model {
  to_real(eps_n) ~ normal(0, sigma[1]);
  to_imag(eps_n) ~ normal(0, sigma[2]);
  sigma ~ //...hyperprior...

  for (n in 1:N) {
    complex eps_n = y[n] - (alpha + beta * x[n]);  // error
    eps_n ~ // ...error distribution...
  }
}
";

w_max = 5 # Max extent of the independent values
w = LinRange(-w_max, w_max, 11)
tmp = Complex[]
for i in w
  for j in w
    append!(tmp, Complex(i, j))
  end
end
w = tmp
df = DataFrame(w = filter(x -> sqrt(real(x)^2 + imag(x)^2) <= w_max, w))
n = length(w)

display(df)



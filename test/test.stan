// test file
data {
  int N;
  real x[N];
}
parameters {
  real mu;
}
model {
  x ~ normal(mu, 1);
}

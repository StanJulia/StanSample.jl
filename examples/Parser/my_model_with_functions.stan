functions {
  int my_local_function(){
    return 1;
  }
  #include my_functions.stan


}

data {
  int<lower=1> N;
  int<lower=0,upper=1> y[N];
}
parameters {
  real<lower=0,upper=1> theta;
}
model {
  model_specific_function();
  theta ~ beta(my_function(),1);
  y ~ bernoulli(theta);
}

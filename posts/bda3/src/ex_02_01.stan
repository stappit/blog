transformed data {
  int tosses = 10;
  int max_heads = 2;
}

parameters {
  real<lower = 0, upper = 1> theta;
}

model {
  theta ~ beta(4, 4); // prior 
  target += binomial_lcdf(max_heads | tosses, theta); // likelihood
}

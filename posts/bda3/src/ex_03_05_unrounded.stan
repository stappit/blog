data {
  int<lower = 1> n;
  vector[n] y; 
}

parameters {
  real mu; 
  real<lower = 0> sigma; 
}

model {
  target += -2 * log(sigma); 
  y ~ normal(mu, sigma);
}

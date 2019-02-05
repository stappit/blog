data {
  int<lower = 1> n;
  int<lower = 1> study[n];
  vector[n] y;
  vector<lower = 0>[n] sigma;
}

parameters {
  real mu;
  real<lower = 0> tau;
  vector[n] theta;
}

model {
  theta ~ normal(mu, tau);
  y ~ normal(theta, sigma);
}

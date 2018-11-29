data {
  int<lower = 0> J; // number of schools 
  vector[J] y; // estimated treatment effects
  vector<lower = 0>[J] sigma; // standard errors
}

parameters {
  real mu; // pop mean
  real<lower = 0> tau; // pop std deviation
  vector[J] eta; // school-level errors
}

transformed parameters {
  vector[J] theta = mu + tau * eta; // school effects
}

model {
  eta ~ normal(0, 1);
  y ~ normal(theta, sigma);
}

data {
  int<lower = 1> n;
  vector[n] y; // rounded measurements
}

parameters {
  real mu; // 'true' weight of the object
  real<lower = 0> sigma; // measurement error
  vector<lower = -0.5, upper = 0.5>[n] err; // rounding error
}

transformed parameters {
  // unrounded values are the rounded values plus some rounding error
  vector[n] z = y + err; // unrounded measurements
}

model {
  target += -2 * log(sigma); // prior
  z ~ normal(mu, sigma);
  // other parameters are uniform
}

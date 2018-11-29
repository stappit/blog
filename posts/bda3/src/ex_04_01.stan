data {
  int<lower = 0> n;
  vector[n] y;
}

parameters {
  real<lower = 0, upper = 1> theta;
}

model {
  y ~ cauchy(theta, 1);
}

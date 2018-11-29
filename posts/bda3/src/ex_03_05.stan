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
  target += log(
    Phi((y + 0.5 - mu) / sigma) - Phi((y - 0.5 - mu) / sigma)
  );
}

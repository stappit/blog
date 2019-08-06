data {
  int<lower=1> N;             // Number of observations
  int<lower=1> K;             // Number of ordinal categories
  int<lower=1, upper=K> y[N]; // Observed ordinals
  int<lower = 1> L;           // Number of distinct levels in the factor
  matrix[N, L] factr;         // 1-hot encoding of factor levels

  // hyper parameters
  real factr_mu;
  real factr_sd;
  real cutpoint_mu;
  real cutpoint_sd;
}

parameters {
  vector[L] beta;   // Latent effect
  ordered[K - 1] c; // cut points
}

model {
  // prior
  beta ~ normal(factr_mu, factr_sd);
  c ~ normal(cutpoint_mu, cutpoint_sd);

  // likelihood
  y ~ ordered_logistic(factr * beta, c);
}

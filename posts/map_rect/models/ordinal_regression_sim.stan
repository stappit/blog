data {
  int<lower = 1> N;     // Number of observations
  int<lower = 1> K;     // Number of ordinal categories
  int<lower = 1> L;     // Number of distinct levels of factor
  matrix[N, L] factr;   // 1-hot encoding

  // hyperparameters
  real factr_mu;
  real factr_sd;
  real cutpoint_mu;
  real cutpoint_sd;
}

generated quantities {
  vector[L] beta;
  ordered[K - 1] c;
  int<lower=1, upper=N> y[N];

  for (i in 1:L) {
    beta[i] = normal_rng(factr_mu, factr_sd);
  }

  for (i in 1:(K-1)) {
    c[i] = normal_rng(cutpoint_mu, cutpoint_sd);
  }
  c = sort_asc(c);

  for (i in 1:N) {
    y[i] = ordered_logistic_rng(factr[i, ] * beta, c);
  }
}

functions {
  vector induced_dirichlet_rng(int K, vector alpha, real phi) {
    vector[K - 1] c;
    vector[K] p = dirichlet_rng(alpha);

    c[1] = phi - logit(1 - p[1]);
    for (k in 2:(K - 1))
      c[k] = phi - logit(inv_logit(phi - c[k - 1]) - p[k]);

    return c;
  }
}

data {
  int<lower = 1> N; // Number of observations
  int<lower = 1> K; // Number of ordinal categories
  int<lower = 1> L; // Number of levels
  matrix[N, L-1] factr;   // 1-hot encoding

  vector<lower = 0>[K] alpha;
  real factr_mu;
  real<lower = 0> factr_sd;
}

generated quantities {
  vector[L-1] beta;
  ordered[K - 1] c = induced_dirichlet_rng(K, alpha, 0); // (Internal) cut points
  int<lower=1, upper=K> y[N];                     // Simulated ordinals

  for (i in 1:(L-1)) {
    beta[i] = normal_rng(factr_mu, factr_sd);
  }

  for (i in 1:N) {
    y[i] = ordered_logistic_rng(factr[i, ] * beta, c);
  }
}

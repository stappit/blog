functions {
  real induced_dirichlet_lpdf(vector c, vector alpha, real phi) {
    int K = num_elements(c) + 1;
    vector[K - 1] sigma = inv_logit(phi - c);
    vector[K] p;
    matrix[K, K] J = rep_matrix(0, K, K);

    // Induced ordinal probabilities
    p[1] = 1 - sigma[1];
    for (k in 2:(K - 1))
      p[k] = sigma[k - 1] - sigma[k];
    p[K] = sigma[K - 1];

    // Baseline column of Jacobian
    for (k in 1:K) J[k, 1] = 1;

    // Diagonal entries of Jacobian
    for (k in 2:K) {
      real rho = sigma[k - 1] * (1 - sigma[k - 1]);
      J[k, k] = - rho;
      J[k - 1, k] = rho;
    }

    return dirichlet_lpdf(p | alpha) + log_determinant(J);
  }
}

data {
  int<lower=1> N;             // Number of observations
  int<lower=1> K;             // Number of ordinal categories
  int<lower=1, upper=K> y[N]; // Observed ordinals
  int<lower = 1> L;           // Number of distinct levels in the factor
  matrix[N, L-1] factr;         // 1-hot encoding of factor levels

  // hyper parameters
  real factr_mu;
  real<lower = 0> factr_sd;
  vector<lower = 0>[K] alpha;
}

parameters {
  vector[L-1] beta;   // Latent effect
  ordered[K - 1] c; // cut points
}

model {
  // prior
  beta ~ normal(factr_mu, factr_sd);
  c ~ induced_dirichlet_lpdf(alpha, 0);

  // likelihood
  y ~ ordered_logistic(factr * beta, c);
}

functions {
  vector lp(vector global, vector local, real[] xr, int[] xi) {
    int M = xi[1];             // first entry is the number of datapoints
    int y[M] = xi[2:M+1];      // remaining entries are the data
    vector[4] c = global[1:4]; // number of cutpoints = 4 is hardcoded :(
    real beta = local[1];      // the parameter for this level is local to this shard

    real ll = ordered_logistic_lpmf(y | rep_vector(beta, M), c);

    return [ll]';
  }

  int[] count(int[] factr, int L) {
    int N = size(factr);
    int counts[L] = rep_array(0, L);
    for (i in 1:N) {
      counts[factr[i]] += 1;
    }
    return counts;
  }

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
  int<lower=1> N;                     // Number of observations
  int<lower=1> K;                     // Number of ordinal categories
  int<lower=1, upper=K> y[N];         // Observed ordinals
  int<lower = 1> L;                   // Number of distinct levels in the factor
  int<lower = 1, upper = L> factr[N]; // Numerical IDs of each level

  real factr_mu;
  real<lower = 0> factr_sd;
  vector<lower = 0>[K] alpha;
}

transformed data {
  // count the number of observations of each factr
  int<lower = 0, upper = N> counts[L] = count(factr, L); // number of observations of each factr

  // shard size is maximum number of observations of any one factr plus 1
  // because we reserve the first entry for the number of observations of each factr
  int<lower = 1> M = max(counts) + 1; // shard size

  int xi[L, max(counts) + 1];  // integer array
  real xr[L, max(counts) + 1]; // real array (unused)

  int<lower = 1> j[L] = rep_array(2, L); // index used in shard definition below
  xi[, 1] = counts; // first entry in each shard defines number of datapoints in the shard

  // define shards
  for (i in 1:N) {
    int shard = factr[i];
    xi[shard, j[shard]] = y[i];
    j[shard] += 1;
  }

  // all other entries are left undefined
  // e.g. xr is completely undefined
  // e.g. xi[i, j] is undefined for j > 1 iff factr[i] has fewer than j - 1 observations
}

parameters {
  // beta is an array of vectors because entry goes to its own shard
  vector[1] beta[L-1]; // latent effect
  ordered[K - 1] c; // cut points
}

model {
  // prior

  vector[1] local[L];

  for (l in 1:(L-1)) {
    beta[l] ~ normal(factr_mu, factr_sd);
  }

  local[1] = rep_vector(0, 1);
  local[2:L] = beta;

  c ~ induced_dirichlet_lpdf(alpha, 0);

  // likelihood
  target += sum(map_rect(lp, c, local, xr, xi));
}

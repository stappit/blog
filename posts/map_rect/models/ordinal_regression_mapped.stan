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
}

data {
  int<lower=1> N;                     // Number of observations
  int<lower=1> K;                     // Number of ordinal categories
  int<lower=1, upper=K> y[N];         // Observed ordinals
  int<lower = 1> L;                   // Number of distinct levels in the factor
  int<lower = 1, upper = L> factr[N]; // Numerical IDs of each level

  real factr_mu;
  real factr_sd;
  real cutpoint_mu;
  real cutpoint_sd;
}

transformed data {
  // count the number of observations of each factr
  int<lower = 0, upper = N> counts[L] = count(factr, L); // number of observations of each factr

  // shard size is maximum number of observations of any one factr plus 1
  // because we reserve the first entry for the number of observations of each factr
  int<lower = 1> M = max(counts) + 1; // shard size

  int xi[L, max(counts) + 1];  // integer array
  real xr[L, max(counts) + 1]; // real array

  int<lower = 1> j = 2; // index used in shard definition below

  // define shards
  // assume factrs are sorted
  // (more generally: if i < j < k and factr[i] = factr[k], then factr[i] = factr[j])
  for (i in 1:N) {

    if (i == 1) {
      j = 2;
    } else if (factr[i - 1] != factr[i]) {
      j = 2;
    } else {
      j += 1;
    }

    xi[factr[i], j] = y[i];
  }

  // first entry in each shard defines number of datapoints in the shard
  xi[, 1] = counts;

  // all other entries are left undefined
  // e.g. xr is completely undefined
  // e.g. xi[i, j] is undefined for j > 1 iff factr[i] has fewer than j - 1 observations
}

parameters {
  // beta is an array of vectors because entry goes to its own shard
  vector[1] beta[L]; // latent effect
  ordered[K - 1] c; // cut points
}

model {
  // prior

  for (l in 1:L) {
    beta[l] ~ normal(factr_mu, factr_sd);
  }

  c ~ normal(cutpoint_mu, cutpoint_sd);

  // likelihood
  target += sum(map_rect(lp, c, beta, xr, xi));
}

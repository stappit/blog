data {
  int<lower = 1> n;       // number of customers
  vector<lower = 0>[n] t; // time between first and last purchase
  vector<lower = 0>[n] T; // total observation time
  vector<lower = 0>[n] k; // number of purchases

  // hyperparameters for the expected lifetime
  real log_life_mean_mu;
  real<lower = 0> log_life_mean_sigma;
  // hyperparameter for scale of customer-level lifetime effects
  real<lower = 0> log_life_scale_sigma;

  // hyperparameters for the expected purchase rate
  real log_lambda_mean_mu;
  real<lower = 0> log_lambda_mean_sigma;
  // hyperparameter for scale of customer-level purchase-rate effects
  real<lower = 0> log_lambda_scale_sigma;

  // flag whether to only sample from the prior
  // to draw from the prior-predictive distribution: prior_only = 1
  // to draw from the posterior distribution: prior_only = 0
  int<lower = 0, upper = 1> prior_only;
}

transformed data {
  vector<lower = 0, upper = 0>[2] zero = rep_vector(0, 2);
  vector[2] J = [-1, 1]';
  vector[2] m = [log_life_mean_mu, log_lambda_mean_mu]';
  matrix<lower = 0>[2, 2] m_sigma = diag_matrix([log_life_mean_sigma, log_lambda_mean_sigma]');
  matrix<lower = 0>[2, 2] s_sigma = diag_matrix([log_life_scale_sigma, log_lambda_scale_sigma]');
}

parameters {
  vector[2] log_centres;
  vector<lower = 0>[2] scales;
  matrix[n, 2] customer; // customer-level effects
}

transformed parameters {
  matrix<lower = 0>[n, 2] theta = exp(diag_post_multiply(customer, J)); // (mu, lambda)
}

model {
  // priors
  log_centres ~ multi_normal_cholesky(m, m_sigma);
  scales ~ multi_normal_cholesky(zero, s_sigma);

  for (i in 1:n) {
    customer[i, ] ~ multi_normal_cholesky(log_centres, diag_matrix(scales));

    // likelihood
    if (prior_only == 0) {
      target += log_sum_exp(
        log(theta[i, 2]) - (theta[i, 2] + theta[i, 1]) .* T[i],
        log(theta[i, 1]) - (theta[i, 2] + theta[i, 1]) .* t[i]
      );
    }

  }

  if (prior_only == 0) {
    target += k .* log(theta[, 2]) - log(theta[, 2] + theta[, 1]);
  }

}

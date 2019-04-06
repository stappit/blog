data {
  int<lower = 1> n;
  vector<lower = 0>[n] t;
  vector<lower = 0>[n] T;
  vector<lower = 0>[n] k;

  real<lower = 0> lambda_mean_alpha;
  real<lower = 0> lambda_mean_beta;
  real<lower = 0> lambda_variance_sigma;
  real<lower = 0> etau_mean_alpha;
  real<lower = 0> etau_mean_beta;
  real<lower = 0> etau_variance_sigma;
}

parameters {
  real<lower = 0> lambda_variance;
  real<lower = 0> lambda_mean;
  vector<lower = 0>[n] lambda;

  real<lower = 0> etau_mean;
  real<lower = 0> etau_variance;
  vector<lower = 0>[n] etau;
}

transformed parameters {
  real<lower = 0> etau_beta = (etau_mean^3 / etau_variance) + etau_mean;
  real<lower = 0> etau_alpha = (etau_mean^2 / etau_variance) + 2;

  real<lower = 0> lambda_beta = lambda_mean / lambda_variance;
  real<lower = 0> lambda_alpha = lambda_mean * lambda_beta;

  vector<lower = 0>[n] mu = 1.0 ./ etau;
}

model {
  // priors
  etau_mean ~ gamma(etau_mean_alpha, etau_mean_beta);
  etau_variance ~ normal(0, etau_variance_sigma);
  etau ~ inv_gamma(etau_alpha, etau_beta);

  lambda_mean ~ gamma(lambda_mean_alpha, lambda_mean_beta);
  lambda_variance ~ normal(0, lambda_variance_sigma);
  lambda ~ gamma(lambda_alpha, lambda_beta);

  // likelihood
  target += k .* log(lambda) - log(lambda + mu);
  for (i in 1:n) {
    target += log_sum_exp(
      log(lambda[i]) - (lambda[i] + mu[i]) .* T[i],
      log(mu[i]) - (lambda[i] + mu[i]) .* t[i]
    );
  }
}

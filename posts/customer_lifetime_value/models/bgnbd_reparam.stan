data {
  int<lower = 1> n;
  vector<lower = 0>[n] time_since_last_purchase;
  vector<lower = 0>[n] span;
  vector<lower = 0>[n] purchases;

  real<lower = 0> lambda_mu_alpha;
  real<lower = 0> lambda_sigma_alpha;
  real<lower = 0> lambda_mu_beta;
  real<lower = 0> lambda_sigma_beta;
}

parameters {
  vector[n] logit_p;
  real logit_p_mu;
  real<lower = 0> logit_p_scale;
  vector<lower = 0>[n] lambda;
  real<lower = 0> lambda_mu;
  real<lower = 0> lambda_sigma;
}

transformed parameters {
  real<lower = 0> lambda_beta = lambda_mu / (lambda_sigma^2);
  real<lower = 0> lambda_alpha = lambda_mu * lambda_beta;
  vector<lower = 0, upper = 1>[n] p = inv_logit(logit_p_mu + logit_p_scale * logit_p);
}

model {
  // priors
  logit_p_mu ~ normal(0, 10);
  logit_p_scale ~ normal(0, 10);
  logit_p ~ normal(0, 1);

  lambda_mu ~ gamma(lambda_mu_alpha, lambda_mu_beta);
  lambda_sigma ~ gamma(lambda_sigma_alpha, lambda_sigma_beta);
  lambda ~ gamma(lambda_alpha, lambda_beta);

  // likelihood
  target += purchases .* log(lambda) + purchases .* log(1 - p) - lambda .* span;
  for (i in 1:n) {
    target += log_mix(p[i], 0, -lambda[i] * time_since_last_purchase[i]);
  }
}

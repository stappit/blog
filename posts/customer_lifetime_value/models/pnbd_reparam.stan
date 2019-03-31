data {
  int<lower = 1> n;
  vector<lower = 0>[n] t;
  vector<lower = 0>[n] T;
  vector<lower = 0>[n] k;

  real log_lambda_mu;
  real<lower = 0> log_lambda_sigma;
  real<lower = 0> log_lambda_scale_sigma;
  real log_mu_mu;
  real<lower = 0> log_mu_sigma;
  real<lower = 0> log_mu_scale_sigma;
}

parameters {
  real log_lambda;
  real log_lambda_scale;
  vector[n] log_lambda_z;

  real log_mu;
  real log_mu_scale;
  vector[n] log_mu_z;
}

transformed parameters {
  vector<lower = 0>[n] mu = exp(log_mu + log_mu_scale * log_mu_z);
  vector<lower = 0>[n] lambda = exp(log_lambda + log_lambda_scale * log_lambda_z);
}

model {
  log_lambda ~ normal(log_lambda_mu, log_lambda_sigma);
  log_lambda_scale ~ normal(0, log_lambda_scale_sigma);
  log_lambda_z ~ normal(0, 1);

  log_mu ~ normal(log_mu_mu, log_mu_sigma);
  log_mu_scale ~ normal(0, log_mu_scale_sigma);
  log_mu_z ~ normal(0, 1);

  target += k .* log(lambda) - log(lambda + mu);
  for (i in 1:n) {
    target += log_sum_exp(
      log(lambda[i]) - (lambda[i] + mu[i]) .* T[i],
      log(mu[i]) - (lambda[i] + mu[i]) .* t[i]
    );
  }
}

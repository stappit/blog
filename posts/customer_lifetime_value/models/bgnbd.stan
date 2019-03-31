data {
  int<lower = 1> n; // number of customers
  vector<lower = 0>[n] time_since_last_purchase;
  vector<lower = 0>[n] span;
  vector<lower = 0>[n] purchases;
}

parameters {
  vector<lower = 0, upper = 1>[n] p; // probability of churning after each purchase
  real<lower = 0> p_alpha;
  real<lower = 0> p_beta;

  vector<lower = 0>[n] lambda; // purchase rate
  real<lower = 0> lambda_alpha;
  real<lower = 0> lambda_beta;
}

model {
  // priors

  // this parameterisation for p seems to yield low bfmi values
  // the draws for p_alpha and p_beta are negatively correlated with energy
  p_alpha ~ gamma(2, 0.0001);
  p_beta ~ gamma(2, 0.0001);
  p ~ beta(p_alpha, p_beta);

  lambda_alpha ~ gamma(2, 0.0001);
  lambda_beta ~ gamma(2, 0.0001);
  lambda ~ gamma(lambda_alpha, lambda_beta);

  // likelihood
  target += purchases .* log(lambda) + purchases .* log(1 - p) - lambda .* span;
  for (i in 1:n) {
    target += log_mix(p[i], 0, -lambda[i] * time_since_last_purchase[i]);
  }
}

data {
  int<lower = 1> n;
  vector<lower = 0>[n] time_since_last_campaign;
  vector<lower = 0>[n] time_to_last_campaign;
  int<lower = 0> campaigns[n];
}

transformed data {
  vector<lower = 0>[n] s = time_to_last_campaign;
  vector<lower = 0>[n] S = time_to_last_campaign + time_since_last_campaign;
}

parameters {
  vector<lower = 0>[n] lambda;
  vector<lower = 0>[n] mu;
}

transformed parameters {
  vector<lower = 0>[n] tau = 1 ./ mu;
  vector<lower = 0, upper = 1>[n] is_churned = exp(-mu .* s)  - exp(-mu .* S);
}

model {
  mu ~ gamma(2, 6);
  target += exponential_lccdf(s | mu);

  lambda ~ gamma(2, 6);
  for (i in 1:n) {
    target += log_mix(
      is_churned[i],
      poisson_lpmf(campaigns[i] | lambda[i] * tau[i]),
      poisson_lpmf(campaigns[i] | lambda[i] * S[i])
    );
  }
}

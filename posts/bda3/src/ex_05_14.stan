data {
  int<lower = 1> n;
  int<lower = 0> total[n];
}

parameters {
  real<lower = 0> alpha;
  real<lower = 0> beta;
  vector<lower = 0>[n] theta;
}

model {
  // hyperprior
  target += -(5. / 2.) * log(alpha + beta); 
  // theta prior 
  theta ~ gamma(alpha, beta); 
  // likelihood
  total ~ poisson(theta); 
}

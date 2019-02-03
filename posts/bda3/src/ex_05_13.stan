data {
  int<lower = 1> n;
  int<lower = 0> total[n];
  int<lower = 0> bikes[n];
}

parameters {
  real<lower = 0> alpha;
  real<lower = 0> beta;
  vector<lower = 0, upper = 1>[n] theta;
}

model {
  // joint prior on alpha, beta
  target += -(5. / 2.) * log(alpha + beta); 
  // theta prior
  theta ~ beta(alpha, beta); 
  // likelihood
  bikes ~ binomial(total, theta); 
}

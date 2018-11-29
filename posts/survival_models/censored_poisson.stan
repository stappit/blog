data {
  // the input data
  int<lower = 1> n;                      // number of observations
  int<lower = 0> tto[n];                 // tto is a list of ints
  int<lower = 0, upper = 1> censored[n]; // list of 0s and 1s
  
  // input parameters for the prior
  real<lower = 0> shape;
  real<lower = 0> rate;
}

parameters {
  // parameters of the model to be estimated
  real<lower = 0> mu; 
}

model {
  // posterior = prior * likelihood
  
  // prior
  mu ~ gamma(shape, rate);
  
  // likelihood
  for (i in 1:n) {
    if (censored[i]) {
      target += poisson_lccdf(tto[i] | mu);  
    } else {
      target += poisson_lpmf(tto[i] | mu);
    }
  }
  
}

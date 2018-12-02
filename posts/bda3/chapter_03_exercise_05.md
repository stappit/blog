---
title: "BDA3 Chapter 3 Exercise 5"
author: "Brian Callander"
date: "2018-10-06"
tags: bda chapter 3, solutions, bayes, rounding error, marginal posterior, measurement error, noninformative prior, normal
tldr: Here's my solution to exercise 5, chapter 3, of Gelman's Bayesian Data Analysis (BDA), 3rd edition.
always_allow_html: yes
output: 
  md_document:
    variant: markdown
    preserve_yaml: yes
---

Here's my solution to exercise 5, chapter 3, of [Gelman's](https://andrewgelman.com/) *Bayesian Data Analysis* (BDA), 3rd edition. There are [solutions](http://www.stat.columbia.edu/~gelman/book/solutions.pdf) to some of the exercises on the [book's webpage](http://www.stat.columbia.edu/~gelman/book/).

<!--more-->

<div style="display:none">
  $\DeclareMathOperator{\dbinomial}{Binomial}
   \DeclareMathOperator{\dbern}{Bernoulli}
   \DeclareMathOperator{\dpois}{Poisson}
   \DeclareMathOperator{\dnorm}{Normal}
   \DeclareMathOperator{\dt}{t}
   \DeclareMathOperator{\dcauchy}{Cauchy}
   \DeclareMathOperator{\dexponential}{Exp}
   \DeclareMathOperator{\duniform}{Uniform}
   \DeclareMathOperator{\dgamma}{Gamma}
   \DeclareMathOperator{\dinvgamma}{InvGamma}
   \DeclareMathOperator{\invlogit}{InvLogit}
   \DeclareMathOperator{\logit}{Logit}
   \DeclareMathOperator{\ddirichlet}{Dirichlet}
   \DeclareMathOperator{\dbeta}{Beta}$
</div>



Suppose we weigh an object 5 times with measurements 


```r
measurements <- c(10, 10, 12, 11, 9)
```




all rounded to the nearest kilogram. Assuming the unrounded measurements are normally distributed, we wish to estimate the weight of the object. We will use the uniform non-informative prior $p(\mu, \log \sigma) \propto 1$.

First, let's assume the measurments are not rounded. Then the marginal posterior mean is $\mu \mid y \sim t_{n - 1}(\bar y, s / \sqrt{n}) = t_4(10.4, 0.51)$.

![plot of chunk mpm_plot](figure/mpm_plot-1..svg)

Now, let's find the posterior assuming rounded measurements. The probability of getting the rounded measurements $y$ is

$$
p(y \mid \mu, \sigma) = \prod_{i = 1}^n \Phi_{\mu, \sigma} (y_i + 0.5) - \Phi_{\mu, \sigma} (y_i - 0.5)
$$

where $\Phi_{\mu, \sigma}$ is the CDF of the $\dnorm(\mu, \sigma)$ distribution. This implies that the posterior is 

$$
p(\mu, \sigma \mid y) \propto \frac{1}{\sigma^2} \prod_{i = 1}^n \Phi_{\mu, \sigma} (y_i + 0.5) - \Phi_{\mu, \sigma} (y_i - 0.5) .
$$

Calculating this marginal posterior mean is pretty difficult, so we'll use [Stan](http://mc-stan.org/) to draw samples. My [first attempt](src/ex_03_05.stan) at writing the model was a direct translation of the maths above. However, it doesn't allow us to infer the unrounded values, as required in part d. The model can be expressed differently by considering the unrounded values as uniformly distributed around the rounded values, i.e. $z_i \sim \duniform (y_i - 0.5, y_i + 0.5)$. 



```r
model <- rstan::stan_model('src/ex_03_05_d.stan')
```


```r
model
```

```
S4 class stanmodel 'ex_03_05_d' coded as follows:
data {
  int<lower = 1> n;
  vector[n] y; // rounded measurements
}

parameters {
  real mu; // 'true' weight of the object
  real<lower = 0> sigma; // measurement error
  vector<lower = -0.5, upper = 0.5>[n] err; // rounding error
}

transformed parameters {
  // unrounded values are the rounded values plus some rounding error
  vector[n] z = y + err; // unrounded measurements
}

model {
  target += -2 * log(sigma); // prior
  z ~ normal(mu, sigma);
  // other parameters are uniform
} 
```

Note that Stan assumes parameters are uniform on their range unless specified otherwise.

Let's also load a model that assumes the measurements are unrounded.


```r
model_unrounded <- rstan::stan_model('src/ex_03_05_unrounded.stan')
```


```r
model_unrounded
```

```
S4 class stanmodel 'ex_03_05_unrounded' coded as follows:
data {
  int<lower = 1> n;
  vector[n] y; 
}

parameters {
  real mu; 
  real<lower = 0> sigma; 
}

model {
  target += -2 * log(sigma); 
  y ~ normal(mu, sigma);
} 
```

Now we can fit the models to the data.


```r
data  = list(
  n = length(measurements),
  y = measurements
)
 
fit <- model %>% 
  rstan::sampling(
    data = data,
    warmup = 1000,
    iter = 5000
  ) 

fit_unrounded <- model_unrounded %>% 
  rstan::sampling(
    data = data,
    warmup = 1000,
    iter = 5000
  ) 
```

We'll also need some draws from the posteriors to make our comparisons.


```r
draws <- fit %>% 
  tidybayes::spread_draws(mu, sigma, z[index]) %>% 
  # spread out z's so that
  # there is one row per draw
  ungroup() %>%  
  mutate(
    index = paste0('z', as.character(index)),
    model = 'rounded'
  ) %>% 
  spread(index, z)

draws_unrounded <- fit_unrounded %>% 
  tidybayes::spread_draws(mu, sigma) %>% 
  mutate(model = 'unrounded') 

draws_all <- draws %>% 
  bind_rows(draws_unrounded)
```

<table class="table table-striped table-hover table-responsive" style="margin-left: auto; margin-right: auto;">
<caption>First few draws from each model</caption>
 <thead>
  <tr>
   <th style="text-align:right;"> mu </th>
   <th style="text-align:right;"> sigma </th>
   <th style="text-align:left;"> model </th>
   <th style="text-align:right;"> z1 </th>
   <th style="text-align:right;"> z2 </th>
   <th style="text-align:right;"> z3 </th>
   <th style="text-align:right;"> z4 </th>
   <th style="text-align:right;"> z5 </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;"> 10.48533 </td>
   <td style="text-align:right;"> 0.9586259 </td>
   <td style="text-align:left;"> rounded </td>
   <td style="text-align:right;"> 9.853187 </td>
   <td style="text-align:right;"> 10.181769 </td>
   <td style="text-align:right;"> 12.33739 </td>
   <td style="text-align:right;"> 10.99090 </td>
   <td style="text-align:right;"> 9.454172 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 10.24142 </td>
   <td style="text-align:right;"> 0.8520584 </td>
   <td style="text-align:left;"> rounded </td>
   <td style="text-align:right;"> 10.350230 </td>
   <td style="text-align:right;"> 9.955655 </td>
   <td style="text-align:right;"> 11.51868 </td>
   <td style="text-align:right;"> 10.92847 </td>
   <td style="text-align:right;"> 8.702736 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 10.63160 </td>
   <td style="text-align:right;"> 0.8305424 </td>
   <td style="text-align:left;"> rounded </td>
   <td style="text-align:right;"> 9.669578 </td>
   <td style="text-align:right;"> 10.053508 </td>
   <td style="text-align:right;"> 12.34553 </td>
   <td style="text-align:right;"> 10.92660 </td>
   <td style="text-align:right;"> 9.420521 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 10.42052 </td>
   <td style="text-align:right;"> 0.8621321 </td>
   <td style="text-align:left;"> unrounded </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 10.33231 </td>
   <td style="text-align:right;"> 1.1500683 </td>
   <td style="text-align:left;"> unrounded </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 10.75089 </td>
   <td style="text-align:right;"> 1.6605005 </td>
   <td style="text-align:left;"> unrounded </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
</tbody>
</table>

The contour plots look very similar but with $\sigma$ shifted upward when we treat the observations as unrounded measurements. This is contrary to my intuition about what should happen: by introducing uncertainty into our measurments, I would have thought we'd see more uncertainty in our parameter estimates.

![plot of chunk contour_plot](figure/contour_plot-1..svg)

The density for $\mu \mid y$ look much the same in both models. This is expected because the rounded measurement is the mean of all possible unrounded measurements.

![plot of chunk mu_plot](figure/mu_plot-1..svg)

The marginal posterior for $\sigma$ again shows a decrease when taking rounding error into account. I'm not sure why that would happen.

![plot of chunk sigma_plot](figure/sigma_plot-1..svg)

<table class="table table-striped table-hover table-responsive" style="margin-left: auto; margin-right: auto;">
<caption>Quantiles for σ | y</caption>
 <thead>
  <tr>
   <th style="text-align:left;"> model </th>
   <th style="text-align:right;"> 5% </th>
   <th style="text-align:right;"> 50% </th>
   <th style="text-align:right;"> 95% </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> rounded </td>
   <td style="text-align:right;"> 0.6041394 </td>
   <td style="text-align:right;"> 1.021596 </td>
   <td style="text-align:right;"> 2.040172 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> unrounded </td>
   <td style="text-align:right;"> 0.6855367 </td>
   <td style="text-align:right;"> 1.088524 </td>
   <td style="text-align:right;"> 2.097022 </td>
  </tr>
</tbody>
</table>


Finally, let's calculate the posterior for $\theta := (z_1 - z_2)^2$ (assuming we observe rounded measurements). 


```r
sims <- draws %>% 
  mutate(theta = (z1 - z2)^2) 
```

![plot of chunk sims_plot](figure/sims_plot-1..svg)


There is a lot of mass near 0 because the observed rounded measurments are the same for $z_1$ and $z_2$. The probability density is also entirely less than 1 because the rounding is off by at most 0.5 in any direction.


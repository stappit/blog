---
always_allow_html: True
author: Brian Callander
date: '2019-02-03'
output:
  md_document:
    preserve_yaml: True
    variant: markdown
tags: |
    bda chapter 3, solutions, gamma-poisson, hierarchical model, stan,
    unsolved
title: BDA3 Chapter 5 Exercise 14
tldr: |
    Here's my solution to exercise 14, chapter 5, of Gelman's Bayesian Data
    Analysis (BDA), 3rd edition.
---

Here's my solution to exercise 14, chapter 5, of
[Gelman's](https://andrewgelman.com/) *Bayesian Data Analysis* (BDA),
3rd edition. There are
[solutions](http://www.stat.columbia.edu/~gelman/book/solutions.pdf) to
some of the exercises on the [book's
webpage](http://www.stat.columbia.edu/~gelman/book/).

<!--more-->
<div style="display:none">

$\DeclareMathOperator{\dbinomial}{Binomial}  \DeclareMathOperator{\dbern}{Bernoulli}  \DeclareMathOperator{\dpois}{Poisson}  \DeclareMathOperator{\dnorm}{Normal}  \DeclareMathOperator{\dt}{t}  \DeclareMathOperator{\dcauchy}{Cauchy}  \DeclareMathOperator{\dexponential}{Exp}  \DeclareMathOperator{\duniform}{Uniform}  \DeclareMathOperator{\dgamma}{Gamma}  \DeclareMathOperator{\dinvgamma}{InvGamma}  \DeclareMathOperator{\invlogit}{InvLogit}  \DeclareMathOperator{\logit}{Logit}  \DeclareMathOperator{\ddirichlet}{Dirichlet}  \DeclareMathOperator{\dbeta}{Beta}$

</div>

We'll use the same dataset as before but only use the total traffic
counts.

``` {.r}
df <- read_csv('data/chapter_03_exercise_08.csv') %>% 
  filter(type == 'residential' & bike_route) %>% 
  transmute(
    i = 1:n(),
    total = bikes + other
  )
```

<table class="table table-striped table-hover table-responsive" style="margin-left: auto; margin-right: auto;">
<thead>
<tr>
<th style="text-align:right;">
i
</th>
<th style="text-align:right;">
total
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
74
</td>
</tr>
<tr>
<td style="text-align:right;">
2
</td>
<td style="text-align:right;">
99
</td>
</tr>
<tr>
<td style="text-align:right;">
3
</td>
<td style="text-align:right;">
58
</td>
</tr>
<tr>
<td style="text-align:right;">
4
</td>
<td style="text-align:right;">
70
</td>
</tr>
<tr>
<td style="text-align:right;">
5
</td>
<td style="text-align:right;">
122
</td>
</tr>
<tr>
<td style="text-align:right;">
6
</td>
<td style="text-align:right;">
77
</td>
</tr>
<tr>
<td style="text-align:right;">
7
</td>
<td style="text-align:right;">
104
</td>
</tr>
<tr>
<td style="text-align:right;">
8
</td>
<td style="text-align:right;">
129
</td>
</tr>
<tr>
<td style="text-align:right;">
9
</td>
<td style="text-align:right;">
308
</td>
</tr>
<tr>
<td style="text-align:right;">
10
</td>
<td style="text-align:right;">
119
</td>
</tr>
</tbody>
</table>
The hyperprior from [exercise 13](./chapter_05_exercise_13.html) was
given by $p(\alpha, \beta) \propto (\alpha, \beta)^{-\frac{5}{2}}$, but
where $\alpha, \beta$ were used as parameters in the beta distribution.
As a first attempt, we'll try using the same priors for our gamma
distribution. Since the support is the same for each, this at least
makes some sense.

The joint posterior is

$$
\begin{align}
  p(\alpha, \beta, \theta \mid y)
  &=
  p(\alpha, \beta)
  \cdot
  \prod_{j = 1}^J 
  p(\theta_j \mid \alpha, \beta)
  \cdot
  p(y_j \mid \theta_j)
  \\
  &=
  (\alpha + \beta)^{-\frac{5}{2}}
  \prod_{j = 1}^J 
  \frac{\beta^\alpha}{\Gamma(\alpha)}
  \theta_j^{\alpha - 1}
  e^{-\beta \theta_j}
  \theta_j^{y_j}
  e^{-\theta_j}
  \\
  &=
  (\alpha + \beta)^{-\frac{5}{2}}
  \frac{\beta^{J\alpha}}{\Gamma(\alpha)^J}
  e^{-(\beta + 1) \sum \theta_j}
  \prod_{j = 1}^J 
  \theta_j^{y_j + \alpha - 1}
  .
\end{align}
$$

I have no idea if it has a finite integral, so we'll just use this for
the rest of the exercise.

Here's the model definition in stan.

``` {.r}
model <- rstan::stan_model('src/ex_05_14.stan')
```

    S4 class stanmodel 'ex_05_14' coded as follows:
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

The model can be fit using some
[tidybayes](https://mjskay.github.io/tidybayes/articles/tidybayes.html)
helpers.

``` {.r}
fit <- model %>% 
  rstan::sampling(
    data = tidybayes::compose_data(df),
    warmup = 1000,
    iter = 5000
  ) %>% 
  tidybayes::recover_types(df)
```

Now draw samples from the posterior.

``` {.r}
draws <- fit %>% 
  tidybayes::spread_draws(alpha, beta, theta[i]) 
```

The posterior joint distribution of $\alpha, \beta$ looks fairly
reasonable. It's concentrated along the diagonal where
$\beta \approx \alpha / 100$, and mainly around $\alpha \approx 2.5$,
$\beta \approx 0.025$.

![Posterior joint density of α,
β.](chapter_05_exercise_14_files/figure-markdown/posterior_alpha_beta_plot-1.svg)

There is little deviation between the observed and estimated values.

![Posterior medians and 95% intervals of traffic based on simulations
from the joint posterior
distribution.](chapter_05_exercise_14_files/figure-markdown/estimated_vs_observed_plot-1.svg)

To estimate total traffic for an unobserved street, we draw
$\alpha, \beta$ from the posterior, draw
$\theta \sim \dgamma(\alpha, \beta)$, then draw
$\tilde y \sim \dpois(\theta)$. The quantiles of $\tilde y$ are then our
posterior predictive interval.

``` {.r}
cis <- draws %>% 
  filter(i == 1) %>% 
  mutate(
    theta = rgamma(n(), alpha, beta),
    y = rpois(n(), theta)
  ) %>% 
  tidybayes::median_qi() %>% 
  select(matches('y|theta'))
```

The 95% posterior interval for $\tilde\theta$ is (20, 290). The 95%
posterior interval of $\tilde y$ is (19, 292), which includes 9 of the
10 observed values.

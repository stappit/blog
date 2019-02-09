---
always_allow_html: True
author: Brian Callander
date: '2019-02-03'
output:
  md_document:
    preserve_yaml: True
    variant: markdown
tags: 'bda chapter 5, solutions, beta-binomial, hierarchical model, stan'
title: BDA3 Chapter 5 Exercise 13
tldr: |
    Here's my solution to exercise 13, chapter 5, of Gelman's Bayesian Data
    Analysis (BDA), 3rd edition.
---

Here's my solution to exercise 13, chapter 5, of
[Gelman's](https://andrewgelman.com/) *Bayesian Data Analysis* (BDA),
3rd edition. There are
[solutions](http://www.stat.columbia.edu/~gelman/book/solutions.pdf) to
some of the exercises on the [book's
webpage](http://www.stat.columbia.edu/~gelman/book/).

<!--more-->
<div style="display:none">

$\DeclareMathOperator{\dbinomial}{Binomial}  \DeclareMathOperator{\dbern}{Bernoulli}  \DeclareMathOperator{\dpois}{Poisson}  \DeclareMathOperator{\dnorm}{Normal}  \DeclareMathOperator{\dt}{t}  \DeclareMathOperator{\dcauchy}{Cauchy}  \DeclareMathOperator{\dexponential}{Exp}  \DeclareMathOperator{\duniform}{Uniform}  \DeclareMathOperator{\dgamma}{Gamma}  \DeclareMathOperator{\dinvgamma}{InvGamma}  \DeclareMathOperator{\invlogit}{InvLogit}  \DeclareMathOperator{\logit}{Logit}  \DeclareMathOperator{\ddirichlet}{Dirichlet}  \DeclareMathOperator{\dbeta}{Beta}$

</div>

``` {.r}
df <- read_csv('data/chapter_03_exercise_08.csv') %>% 
  filter(type == 'residential' & bike_route) %>% 
  transmute(
    i = 1:n(),
    bikes,
    other,
    total = bikes + other,
    rate = bikes / total
  )
```

<table class="table table-striped table-hover table-responsive" style="margin-left: auto; margin-right: auto;">
<caption>
Subset of table 3.3 restricted to residential streets that are bike
routes
</caption>
<thead>
<tr>
<th style="text-align:right;">
i
</th>
<th style="text-align:right;">
bikes
</th>
<th style="text-align:right;">
other
</th>
<th style="text-align:right;">
total
</th>
<th style="text-align:right;">
rate
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
16
</td>
<td style="text-align:right;">
58
</td>
<td style="text-align:right;">
74
</td>
<td style="text-align:right;">
0.2162162
</td>
</tr>
<tr>
<td style="text-align:right;">
2
</td>
<td style="text-align:right;">
9
</td>
<td style="text-align:right;">
90
</td>
<td style="text-align:right;">
99
</td>
<td style="text-align:right;">
0.0909091
</td>
</tr>
<tr>
<td style="text-align:right;">
3
</td>
<td style="text-align:right;">
10
</td>
<td style="text-align:right;">
48
</td>
<td style="text-align:right;">
58
</td>
<td style="text-align:right;">
0.1724138
</td>
</tr>
<tr>
<td style="text-align:right;">
4
</td>
<td style="text-align:right;">
13
</td>
<td style="text-align:right;">
57
</td>
<td style="text-align:right;">
70
</td>
<td style="text-align:right;">
0.1857143
</td>
</tr>
<tr>
<td style="text-align:right;">
5
</td>
<td style="text-align:right;">
19
</td>
<td style="text-align:right;">
103
</td>
<td style="text-align:right;">
122
</td>
<td style="text-align:right;">
0.1557377
</td>
</tr>
<tr>
<td style="text-align:right;">
6
</td>
<td style="text-align:right;">
20
</td>
<td style="text-align:right;">
57
</td>
<td style="text-align:right;">
77
</td>
<td style="text-align:right;">
0.2597403
</td>
</tr>
<tr>
<td style="text-align:right;">
7
</td>
<td style="text-align:right;">
18
</td>
<td style="text-align:right;">
86
</td>
<td style="text-align:right;">
104
</td>
<td style="text-align:right;">
0.1730769
</td>
</tr>
<tr>
<td style="text-align:right;">
8
</td>
<td style="text-align:right;">
17
</td>
<td style="text-align:right;">
112
</td>
<td style="text-align:right;">
129
</td>
<td style="text-align:right;">
0.1317829
</td>
</tr>
<tr>
<td style="text-align:right;">
9
</td>
<td style="text-align:right;">
35
</td>
<td style="text-align:right;">
273
</td>
<td style="text-align:right;">
308
</td>
<td style="text-align:right;">
0.1136364
</td>
</tr>
<tr>
<td style="text-align:right;">
10
</td>
<td style="text-align:right;">
55
</td>
<td style="text-align:right;">
64
</td>
<td style="text-align:right;">
119
</td>
<td style="text-align:right;">
0.4621849
</td>
</tr>
</tbody>
</table>
We'll use the prior on $\alpha$, $\beta$ given in equation 5.9 and
implement it in [Stan](https://mc-stan.org/). Note that stan works on
the log scale, so we increment the posterior density (= `target`) by
$\log\left( (\alpha + \beta)^{-\frac{5}{2}} \right) = -\frac{5}{2}\log(\alpha + \beta)$.
Here is the [model code](src/ex_05_13.stan):

``` {.r}
model <- rstan::stan_model('src/ex_05_13.stan')
```

    S4 class stanmodel 'ex_05_13' coded as follows:
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

Now we calculate the posterior, using
[tidybayes](https://mjskay.github.io/tidybayes/) to take care of passing
the data to stan.

``` {.r}
fit <- model %>% 
  rstan::sampling(data = tidybayes::compose_data(df)) %>% 
  tidybayes::recover_types(df)
```

We don't show any diagnostics here, but there are no divergences, the
rhat is very close to 1, the effective sample size is large, and the
traces look reasonable.

Now we can draw some samples from the posterior.

``` {.r}
draws <- fit %>% 
  tidybayes::spread_draws(alpha, beta, theta[i]) 
```

![Contour plot of the marginal posterior density of (log(α/β), log(α +
β)) for the residential bike route
example.](chapter_05_exercise_13_files/figure-markdown/hyperprior_plot-1.svg)

We can also use our posterior draws to plot the observed (= unpooled)
rates against the estimated rates. In this case, there are no large
differences, although smaller rates seem to be estimated slightly higher
than observed and larger rates lower than observed. All observed rates
are within the posterior intervals of the estimates.

![Posterior medians and 95% intervals of bike observation rates based on
simulations from the join posterior
distribution.](chapter_05_exercise_13_files/figure-markdown/estimate_vs_observed_plot-1.svg)

To calculate a posterior interval for the average underlying proportion
of bike traffic, we sample $\alpha, \beta$ from the posterior, then draw
a new $\tilde\theta \sim \dbeta(\alpha, \beta)$. It wouldn't be correct
to use the values of $\theta_j$ from the model parameters, since those
are estimates from known streets. If we also want an estimate of the
number of bikes observed on a new street (where 100 total vehicles go
by), then we draw $\tilde y \sim \dbinomial(100, \tilde\theta)$ . The
posterior intervals are then just the desired quantiles of the drawn
parameters.

``` {.r}
cis <- draws %>% 
  filter(i == 1) %>% 
  mutate(
    theta = rbeta(n(), alpha, beta),
    y = rbinom(n(), 100, theta)
  ) %>% 
  tidybayes::median_qi() %>% 
  select(matches('y|theta')) 
```

The 95% posterior interval for $\tilde\theta$ is (3.65%, 49.1%), which
includes 10 of the 10 observed rates. The 95% posterior interval of
$\tilde y$ is (3, 49.025), which includes 9 of the 10 observed values.
These intervals seem reasonable, although they are fairly wide. It's
difficult to make a statement about how useful these could be in
application without a concrete idea of what that application is.

---
always_allow_html: True
author: Brian Callander
date: '2019-02-05'
output:
  md_document:
    preserve_yaml: True
    variant: markdown
tags: |
    bda chapter 3, solutions, normal, hierarchical model, posterior
    predictive distribution
title: BDA3 Chapter 5 Exercise 15
tldr: |
    Here's my solution to exercise 15, chapter 5, of Gelman's Bayesian Data
    Analysis (BDA), 3rd edition.
---

Here's my solution to exercise 15, chapter 5, of
[Gelman's](https://andrewgelman.com/) *Bayesian Data Analysis* (BDA),
3rd edition. There are
[solutions](http://www.stat.columbia.edu/~gelman/book/solutions.pdf) to
some of the exercises on the [book's
webpage](http://www.stat.columbia.edu/~gelman/book/).

<!--more-->
<div style="display:none">

$\DeclareMathOperator{\dbinomial}{Binomial}  \DeclareMathOperator{\dbern}{Bernoulli}  \DeclareMathOperator{\dpois}{Poisson}  \DeclareMathOperator{\dnorm}{Normal}  \DeclareMathOperator{\dt}{t}  \DeclareMathOperator{\dcauchy}{Cauchy}  \DeclareMathOperator{\dexponential}{Exp}  \DeclareMathOperator{\duniform}{Uniform}  \DeclareMathOperator{\dgamma}{Gamma}  \DeclareMathOperator{\dinvgamma}{InvGamma}  \DeclareMathOperator{\invlogit}{InvLogit}  \DeclareMathOperator{\logit}{Logit}  \DeclareMathOperator{\ddirichlet}{Dirichlet}  \DeclareMathOperator{\dbeta}{Beta}$

</div>

The [data
provided](http://www.stat.columbia.edu/~gelman/book/data/meta.asc) are
in an awkward format. I've [downloaded
it](data/chapter_05_exercise_15_table_5.4.txt) with minor modifications
to make it easier to parse.

``` {.r}
df <- read_delim(
    'data/chapter_05_exercise_15_table_5.4.txt', 
    delim=' ',
    skip=4,
    trim_ws=TRUE
  ) %>% 
  transmute(
    study,
    y = log(treated.deaths / (treated.total - treated.deaths)) - log(control.deaths / (control.total - control.deaths)),
    sigma2 = (1 / treated.deaths) + (1 / (treated.total - treated.deaths)) + (1 / control.deaths) + (1 / (control.total - control.deaths)),
    sigma = sqrt(sigma2),
    n = treated.total + control.total
  ) %>% 
  select(-sigma2)
```

<table class="table table-striped table-hover table-responsive" style="margin-left: auto; margin-right: auto;">
<caption>
The meta-analysis data from table 5.4, page 124.
</caption>
<thead>
<tr>
<th style="text-align:right;">
study
</th>
<th style="text-align:right;">
y
</th>
<th style="text-align:right;">
sigma
</th>
<th style="text-align:right;">
n
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
0.0281709
</td>
<td style="text-align:right;">
0.8503034
</td>
<td style="text-align:right;">
77
</td>
</tr>
<tr>
<td style="text-align:right;">
2
</td>
<td style="text-align:right;">
-0.7410032
</td>
<td style="text-align:right;">
0.4831516
</td>
<td style="text-align:right;">
230
</td>
</tr>
<tr>
<td style="text-align:right;">
3
</td>
<td style="text-align:right;">
-0.5406212
</td>
<td style="text-align:right;">
0.5645611
</td>
<td style="text-align:right;">
162
</td>
</tr>
<tr>
<td style="text-align:right;">
4
</td>
<td style="text-align:right;">
-0.2461281
</td>
<td style="text-align:right;">
0.1381833
</td>
<td style="text-align:right;">
3053
</td>
</tr>
<tr>
<td style="text-align:right;">
5
</td>
<td style="text-align:right;">
0.0694534
</td>
<td style="text-align:right;">
0.2806564
</td>
<td style="text-align:right;">
720
</td>
</tr>
<tr>
<td style="text-align:right;">
6
</td>
<td style="text-align:right;">
-0.5841569
</td>
<td style="text-align:right;">
0.6757127
</td>
<td style="text-align:right;">
111
</td>
</tr>
<tr>
<td style="text-align:right;">
7
</td>
<td style="text-align:right;">
-0.5123855
</td>
<td style="text-align:right;">
0.1386878
</td>
<td style="text-align:right;">
1884
</td>
</tr>
<tr>
<td style="text-align:right;">
8
</td>
<td style="text-align:right;">
-0.0786233
</td>
<td style="text-align:right;">
0.2039910
</td>
<td style="text-align:right;">
1103
</td>
</tr>
<tr>
<td style="text-align:right;">
9
</td>
<td style="text-align:right;">
-0.4241734
</td>
<td style="text-align:right;">
0.2739730
</td>
<td style="text-align:right;">
560
</td>
</tr>
<tr>
<td style="text-align:right;">
10
</td>
<td style="text-align:right;">
-0.3348234
</td>
<td style="text-align:right;">
0.1170683
</td>
<td style="text-align:right;">
3837
</td>
</tr>
<tr>
<td style="text-align:right;">
11
</td>
<td style="text-align:right;">
-0.2133975
</td>
<td style="text-align:right;">
0.1948720
</td>
<td style="text-align:right;">
1456
</td>
</tr>
<tr>
<td style="text-align:right;">
12
</td>
<td style="text-align:right;">
-0.0389084
</td>
<td style="text-align:right;">
0.2294606
</td>
<td style="text-align:right;">
529
</td>
</tr>
<tr>
<td style="text-align:right;">
13
</td>
<td style="text-align:right;">
-0.5932537
</td>
<td style="text-align:right;">
0.4251674
</td>
<td style="text-align:right;">
584
</td>
</tr>
<tr>
<td style="text-align:right;">
14
</td>
<td style="text-align:right;">
0.2815459
</td>
<td style="text-align:right;">
0.2054455
</td>
<td style="text-align:right;">
1741
</td>
</tr>
<tr>
<td style="text-align:right;">
15
</td>
<td style="text-align:right;">
-0.3213336
</td>
<td style="text-align:right;">
0.2977091
</td>
<td style="text-align:right;">
301
</td>
</tr>
<tr>
<td style="text-align:right;">
16
</td>
<td style="text-align:right;">
-0.1353479
</td>
<td style="text-align:right;">
0.2609219
</td>
<td style="text-align:right;">
420
</td>
</tr>
<tr>
<td style="text-align:right;">
17
</td>
<td style="text-align:right;">
0.1406065
</td>
<td style="text-align:right;">
0.3641742
</td>
<td style="text-align:right;">
373
</td>
</tr>
<tr>
<td style="text-align:right;">
18
</td>
<td style="text-align:right;">
0.3220497
</td>
<td style="text-align:right;">
0.5526449
</td>
<td style="text-align:right;">
305
</td>
</tr>
<tr>
<td style="text-align:right;">
19
</td>
<td style="text-align:right;">
0.4443805
</td>
<td style="text-align:right;">
0.7166491
</td>
<td style="text-align:right;">
308
</td>
</tr>
<tr>
<td style="text-align:right;">
20
</td>
<td style="text-align:right;">
-0.2175097
</td>
<td style="text-align:right;">
0.2598417
</td>
<td style="text-align:right;">
427
</td>
</tr>
<tr>
<td style="text-align:right;">
21
</td>
<td style="text-align:right;">
-0.5910760
</td>
<td style="text-align:right;">
0.2572069
</td>
<td style="text-align:right;">
755
</td>
</tr>
<tr>
<td style="text-align:right;">
22
</td>
<td style="text-align:right;">
-0.6080991
</td>
<td style="text-align:right;">
0.2723787
</td>
<td style="text-align:right;">
1354
</td>
</tr>
</tbody>
</table>
We'll use the model described in the book. Note that by not explicitly
giving a prior for $\mu$ or $\tau$, stan gives them a uniform prior.

``` {.r}
model <- rstan::stan_model('src/ex_05_15.stan')
```

    S4 class stanmodel 'ex_05_15' coded as follows:
    data {
      int<lower = 1> n;
      int<lower = 1> study[n];
      vector[n] y;
      vector<lower = 0>[n] sigma;
    }

    parameters {
      real mu;
      real<lower = 0> tau;
      vector[n] theta;
    }

    model {
      theta ~ normal(mu, tau);
      y ~ normal(theta, sigma);
    } 

Let's fit the model.

``` {.r}
set.seed(57197)

fit <- model %>% 
  sampling(
    data = tidybayes::compose_data(df),
    warmup = 1000,
    iter = 5000
  )
```

We'll draw the posterior population parameters separately from the study
parameters purely for convenience.

``` {.r}
pop_params <- fit %>% 
  tidybayes::spread_draws(mu, tau)

draws <- fit %>% 
  tidybayes::spread_draws(mu, tau, theta[study])
```

The population standard deviation $\tau$ has most of its mass below 0.4.

![A histogram of the posterior draws for
τ.](chapter_05_exercise_15_files/figure-markdown/tau_plot-1.svg)

As in figure 5.6, the effect estimates are almost identical for
$\tau \approx 0$ and spread out as $\tau$ increases.

![Conditional posterior means of treatment effects E(θ | τ, y), as
functions of the between-study standard deviation
τ.](chapter_05_exercise_15_files/figure-markdown/theta_vs_tau-1.svg)

Let's get the median effect estimates with 95% posterior intervals. The
low sample size estimates (dark dots) remain close to the population
mean ($\mu$), whereas the larger sample size estimates (light dots) can
move closer to the unpooled estimates (dotted line).

``` {.r}
cis <- draws %>% 
  median_qi() %>% 
  inner_join(df, by = 'study')
```

![Comparison of the crude effect estimates with the posterior median
effects.](chapter_05_exercise_15_files/figure-markdown/cis_plot-1.svg)

To estimate an effect for a new study, we draw
$\theta \sim \dnorm(\mu, \tau)$.

``` {.r}
new_theta <- pop_params %>% 
  mutate(theta = rnorm(n(), mu, tau)) 
```

``` {.r}
prob_new_theta_positive <- new_theta %>% 
  summarise(sum(theta > 0) / n()) %>% 
  pull() 
```

It has a 7.66% probability of being positive.

![Posterior simulations of a new treatment
effect.](chapter_05_exercise_15_files/figure-markdown/new_theta_plot-1.svg)

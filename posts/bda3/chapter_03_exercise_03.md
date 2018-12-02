---
always_allow_html: True
author: Brian Callander
date: '2018-10-04'
output:
  md_document:
    preserve_yaml: True
    variant: markdown
tags: |
    bda chapter 3, solutions, bayes, normal, t, behrens-fischer, marginal
    posterior
title: BDA3 Chapter 3 Exercise 3
tldr: |
    Here's my solution to exercise 3, chapter 3, of Gelman's Bayesian Data
    Analysis (BDA), 3rd edition.
---

Here's my solution to exercise 3, chapter 3, of
[Gelman's](https://andrewgelman.com/) *Bayesian Data Analysis* (BDA),
3rd edition. There are
[solutions](http://www.stat.columbia.edu/~gelman/book/solutions.pdf) to
some of the exercises on the [book's
webpage](http://www.stat.columbia.edu/~gelman/book/).

<!--more-->
<div style="display:none">

$\DeclareMathOperator{\dbinomial}{Binomial}  \DeclareMathOperator{\dbern}{Bernoulli}  \DeclareMathOperator{\dpois}{Poisson}  \DeclareMathOperator{\dnorm}{Normal}  \DeclareMathOperator{\dt}{t}  \DeclareMathOperator{\dcauchy}{Cauchy}  \DeclareMathOperator{\dexponential}{Exp}  \DeclareMathOperator{\dgamma}{Gamma}  \DeclareMathOperator{\dinvgamma}{InvGamma}  \DeclareMathOperator{\invlogit}{InvLogit}  \DeclareMathOperator{\logit}{Logit}  \DeclareMathOperator{\ddirichlet}{Dirichlet}  \DeclareMathOperator{\dbeta}{Beta}$

</div>

Suppose we have $n$ measurements
$y \mid \mu, \sigma \sim \dnorm(\mu, \sigma)$, where the prior
$p(\mu, \log \sigma) \propto 1$ is uniform. The calculations on page 66
show that the marginal posterior distribution of $\mu$ is
$\mu \mid y \sim \dt(\bar y, s / n)$, where $s$ is the sample standard
deviation. The measurements are as follows.

``` {.r}
control <- list(
  n = 32,
  mean = 1.013,
  sd = 0.24
)

treatment <- list(
  n = 36,
  mean = 1.173,
  sd = 0.2
)
```

The t-distribution in base-R is a standardised t-distribution. For a
more general t-distribution (with arbitrary location and scale), we'll
use the
[LaplacesDemon](https://www.rdocumentation.org/packages/LaplacesDemon/versions/16.1.1)
package.

``` {.r}
library(LaplacesDemon)
```

This allows us to plot the marginal posterior means.

``` {.r}
mp <- tibble(value = seq(0, 2, 0.01)) %>% 
  mutate(
    ctrl = dst(value, control$mean, control$sd / sqrt(control$n), control$n - 1),
    trt = dst(value, treatment$mean, treatment$sd / sqrt(treatment$n), treatment$n - 1)
  ) %>% 
  gather(cohort, density, ctrl, trt) 
```

![](chapter_03_exercise_03_files/figure-markdown/mp_plot-1.png)

The 95% credible interval of the marginal posterior means is:

``` {.r}
draws <- 10000

difference <- tibble(draw = 1:draws) %>% 
  mutate(
    ctrl = rst(n(), control$mean, control$sd / sqrt(control$n), control$n - 1),
    trt = rst(n(), treatment$mean, treatment$sd / sqrt(treatment$n), treatment$n - 1),
    difference = trt - ctrl
  ) 

ci <- difference$difference %>% 
  quantile(probs = c(0.05, 0.95)) 

ci
```

            5%        95% 
    0.06752309 0.25173035 

We can also plot the distribution of the difference.

![](chapter_03_exercise_03_files/figure-markdown/diffs_plot-1.png)

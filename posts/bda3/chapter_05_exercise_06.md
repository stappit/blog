---
title: "BDA3 Chapter 5 Exercise 6"
author: "Brian Callander"
date: "2018-11-11"
tags: bda chapter 5, solutions, bayes, mixture, exchangeability, divorce rates
tldr: Here's my solution to exercise 6, chapter 5, of Gelman's Bayesian Data Analysis (BDA), 3rd edition.
always_allow_html: yes
output: 
  md_document:
    variant: markdown
    preserve_yaml: yes
---

Here's my solution to exercise 6, chapter 5, of [Gelman's](https://andrewgelman.com/) *Bayesian Data Analysis* (BDA), 3rd edition. There are [solutions](http://www.stat.columbia.edu/~gelman/book/solutions.pdf) to some of the exercises on the [book's webpage](http://www.stat.columbia.edu/~gelman/book/).

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



We are given that the divorce rates (per thousand population) for eight states were recorded, two of which were Utah and Nevada. However, we are not told which rates correspond to which states. We are then given the rates for the first seven of the selected states and we need to calculate the posterior for the divorce rate of the remaining state.

Our prior needs to be exchangeable, and to take into account the fact that one state (Utah) is likely to have an especially low divorce rate and that other (Nevada) is likely to have an especially high divorce rate. If we knew that $y_1$ and $y_2$ were Utah and Nevada, respectively, we could use the following product of betas

$$
p(\theta_1, \dotsc, \theta_8)
=
\dbeta(\theta_1 \mid \alpha_l, \beta_l)
\cdot
\dbeta(\theta_2 \mid \alpha_h, \beta_h)
\cdot
\prod_{i = 3}^8
\dbeta(\theta_i \mid \alpha_m, \beta_m)
,
$$

where $(\alpha_l, \beta_l)$, $(\alpha_m, \beta_m)$, and $(\alpha_h, \beta_h)$ have most of their density on low, medium, and high values, respectively. Since we don't know which belong to Utah and Nevada, we can average this density over all possible combinations:

$$
p(\theta_1, \dotsc, \theta_8)
=
\frac{1}{56}
\sum_f
\dbeta(\theta_{f(1)} \mid \alpha_l, \beta_l)
\cdot
\dbeta(\theta_{f(2)} \mid \alpha_h, \beta_h)
\cdot
\prod_{i = 3}^8
\dbeta(\theta_{f(i)} \mid \alpha_m, \beta_m)
,
$$

where $f: \{1, \dotsc, 8 \} \to \{1, \dotsc, 8 \}$ is either identity or is a permuation such that 1 and 2 are not both fixed points. There are $2 \binom{8}{2} = 8 \times 7 = 56$ such functions.

We'll use the following hyperpriors.


```r
low <- list(alpha = 7, beta = 2000 - 7)
medium <- list(alpha = 65, beta = 10000 - 65)
high <- list(alpha = 22, beta = 2000 - 22)
```



The medium prior has probability mass 2.33%, 3.75% below and above 0.5%, 0.8%, respecitvely, with a mean value of 0.65%. The low and high priors have a lower precision but with means that are lower and higher than 0.65%, respectively. They also overlap somewhat with the medium prior, but with lower density. This overlapping could allow the possibility that Nevada/Utah don't have such extreme values in the year of observation.

![plot of chunk priors_plot](figure/priors_plot-1..svg)

The posterior for the eighth state is

$$
p(\theta_8 \mid \theta_1, \dotsc, \theta_7)
=
\frac{p(\theta_1, \dotsc, \theta_8)}{p(\theta_1, \dotsc, \theta_7)}
.
$$

We can plot this posterior by writing functions for the denominator and numerator. First the numerator.


```r
djoint8 <- function(x) {
  
  # x is a vector of length 8
  
  # calculate the densities once
  hdensity <- x %>% map_dbl(dbeta, high$alpha, high$beta)
  mdensity <- x %>% map_dbl(dbeta, medium$alpha, medium$beta)
  ldensity <- x %>% map_dbl(dbeta, low$alpha, low$beta)

  # i is the index for the low divorce rate state
  # j is the index for the high divorce rate state
  # k is the index for the medium divorce rate states
  expand.grid(i = 1:8, j = 1:8, k = 1:8) %>% 
    filter(i != j & i != k & j != k) %>% 
    mutate(m = mdensity[k]) %>% 
    group_by(i, j) %>% 
    summarise(m = prod(m)) %>% 
    ungroup() %>% 
    mutate(density = m * ldensity[i] * hdensity[j]) %>% 
    # average over all choices of i, j
    summarise(mean(density)) %>% 
    pull() %>% 
    return()
}

0.0065 %>% 
  rep(8) %>% 
  djoint8()
```

```
[1] 9.611221e+18
```

Now the denominator. Given the ordering, the joint prior is independent. This means that integrating out the eighth state simply means dropping any density for the eighth state.


```r
djoint7 <- function(x) {
  
  # x is a vector of length 7

  hdensity <- x %>% map_dbl(dbeta, high$alpha, high$beta)
  mdensity <- x %>% map_dbl(dbeta, medium$alpha, medium$beta)
  ldensity <- x %>% map_dbl(dbeta, low$alpha, low$beta)

  # We drop the eighth state from the medium components
  # by limiting the range of k
  expand.grid(i = 1:8, j = 1:8, k = 1:7) %>% 
    filter(i != j & i != k & j != k) %>% 
    mutate(m = mdensity[k]) %>% 
    group_by(i, j) %>% 
    summarise(m = prod(m)) %>% 
    ungroup() %>% 
    mutate(
      # if i or j is the eighth state,
      # we drop it
      # otherwise we have both factors
      density = m * case_when(
        j == 8 ~ ldensity[i],
        i == 8 ~ hdensity[j],
        TRUE ~ ldensity[i] * hdensity[j]
      )
    ) %>% 
    summarise(mean(density)) %>% 
    pull() %>% 
    return()
}

0.0065 %>% 
  rep(7) %>% 
  djoint7()
```

```
[1] 1.103857e+17
```

The posterior is then just the ratio of the two densities given above.


```r
y <- c(5.8, 6.6, 7.8, 5.6, 7.0, 7.1, 5.4) / 1000

dposterior <- function(x, .y = y) {
  z <- c(.y, x)
  djoint8(z) / djoint7(.y)
}

dposterior(0.006)
```

```
[1] 157.0397
```

Let's calculate the posterior on a grid with the bulk of the density.


```r
granularity <- 0.00005

posterior <- tibble(p = seq(0, 0.03, granularity)) %>% 
  mutate(density = map_dbl(p, dposterior))
```

To check that we have most of the density, we can calculate the area under the density curve on our grid. It is 100%, which is encouraging.


```r
posterior %>% 
  summarise(sum(density) * granularity) %>% 
  pull() %>% 
  percent()
```

```
[1] "100%"
```

We can also check the probability of observing a value at least as extreme as the value actually observed.


```r
extreme <- posterior %>% 
  filter(p >= 0.0139) %>% 
  summarise(sum(density) * granularity) %>% 
  pull() %>% 
  percent()

extreme 
```

```
[1] "4.22%"
```

The posterior has the following shape. There are three modes since the eighth state can correspond to a low, medium, or high divorce rate.

![plot of chunk posterior_plot](figure/posterior_plot-1..svg)

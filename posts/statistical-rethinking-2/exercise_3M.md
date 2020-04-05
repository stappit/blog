---
always_allow_html: yes
author: Brian Callander
date: '2020-04-05'
output:
  md_document:
    preserve_yaml: yes
    variant: markdown
tags: |
    statistical rethinking, solutions, grid approximation, posterior
    probability, posterior predictive probability, hpdi, binomial
title: SR2 Chapter 3 Medium
tldr: |
    Here's my solution to the medium exercises in chapter 3 of McElreath's
    Statistical Rethinking, 2nd edition.
---

Here's my solution to the medium exercises in chapter 3 of McElreath's
Statistical Rethinking, 2nd edition.

<!--more-->
<div>

$\DeclareMathOperator{\dbinomial}{Binomial}  \DeclareMathOperator{\dbernoulli}{Bernoulli}  \DeclareMathOperator{\dpoisson}{Poisson}  \DeclareMathOperator{\dnormal}{Normal}  \DeclareMathOperator{\dt}{t}  \DeclareMathOperator{\dcauchy}{Cauchy}  \DeclareMathOperator{\dexponential}{Exp}  \DeclareMathOperator{\duniform}{Uniform}  \DeclareMathOperator{\dgamma}{Gamma}  \DeclareMathOperator{\dinvpamma}{Invpamma}  \DeclareMathOperator{\invlogit}{InvLogit}  \DeclareMathOperator{\logit}{Logit}  \DeclareMathOperator{\ddirichlet}{Dirichlet}  \DeclareMathOperator{\dbeta}{Beta}$

</div>

Assuming Earth has 70% water cover, and we observe water 8 times out of
15 globe tosses, let's calculate some posterior quantities with two
choices of prior: uniform and step.

``` {.r}
p_true <- 0.7

W <- 8
N <- 15

granularity <- 1000 # points on the grid
```

Uniform Prior
-------------

We calculate the grid approximation of the posterior as shown in the
book.

``` {.r}
m1_grid <- tibble(p = seq(0, 1, length.out = granularity)) %>% 
  mutate(prior = 1)

m1_posterior <- m1_grid %>% 
  mutate(
    likelihood = dbinom(W, N, p),
    posterior = prior * likelihood
  )
```

![Solution to exercise
3M1](exercise_3M_files/figure-markdown/m1_plot-1.svg)

We can get draws from our posterior by sampling the water cover values
many times with replacement, each value being drawn in proportion to the
posterior probability. We can then just summarise these draws to get the
desired interval.

``` {.r}
m2_samples <- m1_posterior %>% 
  sample_n(10000, replace = T, weight = posterior)

m2_hpdi <- HPDI(m2_samples$p, prob = 0.9)
m2_hpdi
```

         |0.9      0.9| 
    0.3223223 0.7097097 

The histogram looks as follows. This is much the same as the previous
graph, but calculated from the samples.

![Solution to exercise
3M2](exercise_3M_files/figure-markdown/m2_plot-1.svg)

To get the posterior predictive sample, we take our posterior draws of
$p$, then use them to draw a random number of observed water tosses out
of 15. The fraction of posterior predictive samples with a given value
is then the posterior predictive probability of that value.

``` {.r}
m3_prob <- m2_samples %>% 
  mutate(W = rbinom(n(), 15, p)) %>% 
  group_by(W) %>% 
  tally() %>% 
  mutate(probability = n / sum(n))
```

![Solution to exercise
3M3](exercise_3M_files/figure-markdown/m3_plot-1.svg)

We can also calculate the posterior predictive probabilities with a
different number of tosses. Here with 9 tosses.

``` {.r}
m4_prob <- m2_samples %>% 
  mutate(W = rbinom(n(), 9, p)) %>% 
  group_by(W) %>% 
  tally() %>% 
  mutate(probability = n / sum(n))
```

![Solution to exercise
3M4](exercise_3M_files/figure-markdown/m4_plot-1.svg)

Step Prior
----------

Now we repeat the same steps but with the step prior instead of the
uniform prior. We'll just repeat it without comment.

``` {.r}
m5_grid <- m1_grid %>% 
  mutate(prior = if_else(p < 0.5, 0, 1))

m5_posterior <- m5_grid %>% 
  mutate(
    likelihood = dbinom(W, N, p),
    posterior = prior * likelihood
  )
```

![Solution to exercise 3M5 part
1](exercise_3M_files/figure-markdown/m5_1_plot-1.svg)

``` {.r}
m5_samples <- m5_posterior %>% 
  sample_n(10000, replace = T, weight = posterior)

m5_hpdi <- HPDI(m5_samples$p, prob = 0.9)
m5_hpdi
```

         |0.9      0.9| 
    0.5005005 0.7107107 

![Solution to exercise 3M5 part
2](exercise_3M_files/figure-markdown/m5_2_plot-1.svg)

``` {.r}
m5_prob <- m5_samples %>% 
  mutate(W = rbinom(n(), 15, p)) %>% 
  group_by(W) %>% 
  tally() %>% 
  mutate(probability = n / sum(n))
```

![Solution to exercise 3M5 part
3](exercise_3M_files/figure-markdown/m5_3_plot-1.svg)

``` {.r}
m5_prob <- m5_samples %>% 
  mutate(W = rbinom(n(), 9, p)) %>% 
  group_by(W) %>% 
  tally() %>% 
  mutate(probability = n / sum(n))
```

![Solution to exercise 3M5 part
4](exercise_3M_files/figure-markdown/m5_4_plot-1.svg)

Let's compare the proportion of samples within 0.05 of the true value
for each prior.

``` {.r}
p_close_uniform <- m2_samples %>% 
  group_by(close = p %>% between(p_true - 0.05, p_true + 0.05)) %>% 
  tally() %>% 
  mutate(probability = n / sum(n)) %>% 
  filter(close) %>% 
  pull(probability)

p_close_step <- m5_samples %>% 
  group_by(close = p %>% between(p_true - 0.05, p_true + 0.05)) %>% 
  tally() %>% 
  mutate(probability = n / sum(n)) %>% 
  filter(close) %>% 
  pull(probability)
```

The probability of being close to the true value under the uniform and
step priors is 0.1316 and 0.2157, respectively. The step prior thus has
more mass around the true value.

Exercise 3M6
------------

Bayesian models are generative, meaning we can simulate new datasets
according to our prior probabilities. We'll simulate 10 datasets for
each value of N of interest. We simulate a dataset by randomly choosing
a `p_true` from our uniform prior, then randomly choosing a `W` from the
corresponding binomial distribution.

``` {.r}
m6_prior_predictive <- crossing(
    N = 200 * (1:16), 
    iter = 1:10
  ) %>% 
  mutate(
    p_true = runif(n(), min=0, max=1), 
    W = rbinom(n(), N, p_true)
  )
```

For each of these simulated datasets, we grid approximate the posterior,
take posterior samples, then calculate the HPDI.

``` {.r}
m6_grid <- tibble(p = seq(0, 1, length.out = granularity)) %>% 
  mutate(prior = 1)

m6_posteriors <- m6_prior_predictive %>% 
  crossing(m6_grid) %>% 
  group_by(N, p_true, iter) %>% 
  mutate(
    likelihood = dbinom(W, N, p),
    posterior = prior * likelihood
  )

m6_samples <- m6_posteriors %>% 
  sample_n(1000, replace = TRUE, weight = posterior) 

m6_hpdi <- m6_samples %>% 
  summarise(lo = HPDI(p, 0.99)[1], hi = HPDI(p, 0.99)[2]) %>% 
  mutate(width = abs(hi - lo))
```

Now for each value of N, we check how many of the intervals have the
desired width.

``` {.r}
m6_n <- m6_hpdi %>% 
  group_by(N) %>% 
  summarise(fraction = mean(width < 0.05)) 
```

![Solution to exercise
3M6](exercise_3M_files/figure-markdown/m6_sample_size_plot-1.svg)

Thus we expect a sample size around 2600-3000 to give us a sufficiently
precise posterior estimation.

---
title: "BDA3 Chapter 2 Exercise 11"
author: "Brian Callander"
date: "2018-09-01"
tags: bda chapter 2, solutions, bayes, cauchy, posterior predictive, grid approximation
tldr: Here's my solution to exercise 11, chapter 2, of Gelman's Bayesian Data Analysis (BDA), 3rd edition.
always_allow_html: yes
output: 
  md_document:
    variant: markdown
    preserve_yaml: yes
---

Here's my solution to exercise 11, chapter 2, of [Gelman's](https://andrewgelman.com/) *Bayesian Data Analysis* (BDA), 3rd edition. There are [solutions](http://www.stat.columbia.edu/~gelman/book/solutions.pdf) to some of the exercises on the [book's webpage](http://www.stat.columbia.edu/~gelman/book/).

<!--more-->

<div style="display:none">
  $\DeclareMathOperator{\dbinomial}{binomial}
   \DeclareMathOperator{\dbern}{Bernoulli}
   \DeclareMathOperator{\dnorm}{normal}
   \DeclareMathOperator{\dcauchy}{Cauchy}
   \DeclareMathOperator{\dgamma}{gamma}
   \DeclareMathOperator{\invlogit}{invlogit}
   \DeclareMathOperator{\logit}{logit}
   \DeclareMathOperator{\dbeta}{beta}$
</div>




Assume the sampling distribution is $\dcauchy(y \mid \theta, 1)$ with uniform prior $p(\theta) \propto 1$ on $[0, 100]$. Given observations $y$, we can approximate the posterior for $\theta$ by dividing the interval $[0, 100]$ into partitions of length $\frac{1}{m}$. The unnormalised posterior for $\theta$ on this grid is then computed as follows.


```r
# observations
y <- c(43, 44, 45, 46.5, 47.5) 

# grid granularity
m <- 100

# L(θ) := p(y | θ)
likelihood <- function(theta) 
  y %>% 
    map(dcauchy, theta, 1) %>% 
    reduce(prod)

# unnormalised posterior grid
posterior_unnorm <- tibble(theta = seq(0, 100, 1 / m)) %>% 
  mutate(density = map(theta, likelihood) %>% unlist())
```

We can approximate the normalising constant by summing the approximate area on each partition. Each partition has width $\frac{1}{m}$ and approximate height given by the density, so the approximate area is the multiple of the two.


```r
# grid approx to area under curve
normalising_constant <- posterior_unnorm %>% 
  summarise(sum(density) / m) %>% 
  pull()

# normalised posterior grid
posterior <- posterior_unnorm %>% 
  mutate(density = density / normalising_constant)

normalising_constant
```

```
[1] 3.418359e-05
```

![plot of chunk posterior_plot](figure/posterior_plot-1.png)

Let's zoom in on the region $[40, 50]$ where most of the density lies.

![plot of chunk posterior_plot_zoomed](figure/posterior_plot_zoomed-1.png)

Sampling from this posterior yields a histogram with a similar shape.


```r
posterior_draws <- posterior %>% 
  sample_n(1000, replace = TRUE, weight = density) %>% 
  select(theta)
```

![plot of chunk posterior_sample_plot](figure/posterior_sample_plot-1.png)

We can draw from the posterior predictive distribution by first drawing $\tilde\theta$ from the posterior of $\theta$, then drawing $\tilde y$ from $\dcauchy(\tilde\theta, 1)$. The tails of the posterior predictive distribution are much wider than for $\theta$ so we plot this histogram on the interval $[10, 90]$ (although there are a few observations outside this interval).


```r
posterior_predictive <- posterior_draws %>% 
  mutate(pp = rcauchy(n(), theta, 1)) 
```

![plot of chunk posterior_predictive_plot](figure/posterior_predictive_plot-1.png)

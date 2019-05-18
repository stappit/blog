---
always_allow_html: yes
author: Brian Callander
date: '2018-08-27'
output:
  md_document:
    preserve_yaml: yes
    variant: markdown
tags: 'bda chapter 2, bda, solutions, bayes, normal, posterior predictive'
title: BDA3 Chapter 2 Exercise 8
tldr: |
    Here's my solution to exercise 8, chapter 2, of Gelman's Bayesian Data
    Analysis (BDA), 3rd edition.
---

Here's my solution to exercise 8, chapter 2, of
[Gelman's](https://andrewgelman.com/) *Bayesian Data Analysis* (BDA),
3rd edition. There are
[solutions](http://www.stat.columbia.edu/~gelman/book/solutions.pdf) to
some of the exercises on the [book's
webpage](http://www.stat.columbia.edu/~gelman/book/).

<!--more-->
<div>

$\DeclareMathOperator{\dbinomial}{binomial}  \DeclareMathOperator{\dbern}{Bernoulli}  \DeclareMathOperator{\dnorm}{normal}  \DeclareMathOperator{\dgamma}{gamma}  \DeclareMathOperator{\invlogit}{invlogit}  \DeclareMathOperator{\logit}{logit}  \DeclareMathOperator{\dbeta}{beta}$

</div>

With prior $\theta \sim \dnorm(180, 40)$, sampling distribution
$y \mid \theta \sim \dnorm(\theta, 20)$, and $n$ sampled students with
average weight $\bar y = 150$, it follows from 2.11 that the posterior
mean is

$$
\begin{align}
  \mu
  :=
  \mathbb E(\theta \mid \bar y) 
  &=
  \frac{\frac{180}{1600} + \frac{150n}{400}}{\frac{1}{1600} + \frac{n}{400}} 
  \\
  &=
  \frac{60(3 + 10n)}{1600} \cdot \frac{1600}{1 + 4n}
  \\
  &=
  \frac{60(3 + 10n)}{1 + 4n}
  \\
  1 / \sigma^2 
  :=
  1 / \mathbb V (\theta \mid \bar y)
  &=
  \frac{1}{1600} + \frac{n}{400}
  \\
  &=
  \frac{1 + 4n}{1600}
  .
\end{align}
$$

So
$\theta \mid \bar y \sim \dnorm \left( \frac{60(3 + 10n)}{1 + 4n}, \frac{40}{\sqrt{1 + 4n}} \right)$.
When $n = 0$ this is exactly the prior, and when $n = \infty$ this is
150 (the observed mean) with zero variance.

It follows from the calculations shown in the book that the posterior
predictive distribution is
$\tilde y \mid y \sim \dnorm(\mu, \sqrt{\sigma^2 + 400})$.

We can obtain 95% posterior intervals as follows.

``` {.r}
mu <- function(n) 60 * (3 + 10 * n) / (1 + 4 * n)
sigma <- function(n) 40 / sqrt(1 + 4 * n)

percentiles <- c(0.05, 0.95)

theta_posterior_interval <- qnorm(percentiles, mu(10), sigma(10))
y_posterior_interval <- qnorm(percentiles, mu(10), sqrt(sigma(10)^2 + 400))
```

With a sample of size of 10, we get θ ϵ \[140.5, 161\] and $\tilde y$ ϵ
\[116.3, 185.2\].

``` {.r}
theta_posterior_interval <- qnorm(percentiles, mu(100), sigma(100))
y_posterior_interval <- qnorm(percentiles, mu(100), sqrt(sigma(100)^2 + 400))
```

With a sample of size of 100, we get θ ϵ \[146.8, 153.4\] and $\tilde y$
ϵ \[117, 183.1\].

Both of these posterior intervals for $\theta$ are very similar to the
frequentist confidence intervals, especially in the case $n = 100$.

``` {.r}
qnorm(percentiles, 150, 20 / sqrt(10))
```

    ## [1] 139.597 160.403

``` {.r}
qnorm(percentiles, 150, 20 / sqrt(100))
```

    ## [1] 146.7103 153.2897

We would expect them to become more similar as $n$ increases, because
both means and standard deviations converge to the same values for large
$n$.

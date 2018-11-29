---
always_allow_html: True
author: Brian Callander
date: '2018-08-27'
output:
  md_document:
    preserve_yaml: True
    variant: markdown
tags: 'bda chapter 2, bda, solutions, bayes, normal, posterior predictive'
title: BDA3 Chapter 2 Exercise 8
---

Here's my solution to exercise 8, chapter 2, of
[Gelman's](https://andrewgelman.com/) *Bayesian Data Analysis* (BDA),
3rd edition. There are
[solutions](http://www.stat.columbia.edu/~gelman/book/solutions.pdf) to
some of the exercises on the [book's
webpage](http://www.stat.columbia.edu/~gelman/book/).

<!--more-->
<div style="display:none">

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
$\theta \mid \bar y ~ \dnorm \left( \frac{60(3 + 10n)}{1 + 4n}, \frac{40}{\sqrt{1 + 4n}} \right)$.

It follows from the calculations shown in the book that the posterior
predictive distribution is
$\tilde y \mid y \sim \dnorm(\mu, \sigma + 20)$.

We can obtain 95% posterior intervals as follows.

``` {.r}
mu <- function(n) 60 * (3 + 10 * n) / (1 + 4 * n)
sigma <- function(n) 40 / sqrt(1 + 4 * n)

percentiles <- c(0.05, 0.95)

theta_posterior_interval <- qnorm(percentiles, mu(10), sigma(10))
y_posterior_interval <- qnorm(percentiles, mu(10), sigma(10) + 20)
```

With a sample of size of 10, we get θ ϵ \[140.5, 161\] and $\tilde y$ ϵ
\[107.6, 193.9\].

``` {.r}
theta_posterior_interval <- qnorm(percentiles, mu(100), sigma(100))
y_posterior_interval <- qnorm(percentiles, mu(100), sigma(100) + 20)
```

With a sample of size of 100, we get θ ϵ \[146.8, 153.4\] and $\tilde y$
ϵ \[113.9, 186.3\].

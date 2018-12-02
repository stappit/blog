---
title: "BDA3 Chapter 2 Exercise 15"
author: "Brian Callander"
date: '2018-09-04'
tags: bda chapter 2, solutions, bayes, beta, mean, variance
tldr: Here's my solution to exercise 15, chapter 2, of Gelman's Bayesian Data Analysis (BDA), 3rd edition.
---

Here's my solution to exercise 15, chapter 2, of [Gelman's](https://andrewgelman.com/) *Bayesian Data Analysis* (BDA), 3rd edition. There are [solutions](http://www.stat.columbia.edu/~gelman/book/solutions.pdf) to some of the exercises on the [book's webpage](http://www.stat.columbia.edu/~gelman/book/).

<!--more-->

<div style="display:none">
  $\DeclareMathOperator{\dbinomial}{binomial}
   \DeclareMathOperator{\dbern}{Bernoulli}
   \DeclareMathOperator{\dpois}{Poisson}
   \DeclareMathOperator{\dnorm}{normal}
   \DeclareMathOperator{\dcauchy}{Cauchy}
   \DeclareMathOperator{\dgamma}{gamma}
   \DeclareMathOperator{\invlogit}{invlogit}
   \DeclareMathOperator{\logit}{logit}
   \DeclareMathOperator{\dbeta}{beta}$
</div>

Suppose $Z \sim \dbeta(\alpha, \beta)$. Then for $m, n \in \mathbb N$ we have

$$
\begin{align}
  \mathbb E \left[ Z^m (1 - Z)^n \right]
  &=
  \frac{1}{B(\alpha, \beta)} \int_0^1 z^m (1 - z)^n z^{\alpha - 1} (1 - z)^{\beta - 1} dz
  \\
  &=
  \frac{1}{B(\alpha, \beta)} \int_0^1 z^{m + \alpha - 1} (1 - z)^{n + \beta - 1} dz
  \\
  &=
  \frac{1}{B(\alpha, \beta)} \frac{\Gamma (m + \alpha) \Gamma( n + \beta )}{\Gamma (m + n + \alpha + \beta)}
  \\
  &=
  \frac{(\alpha + \beta -1)!}{(\alpha - 1)! (\beta - 1)!} \frac{(m + \alpha - 1)! (n + \beta - 1)!}{(m + n + \alpha + \beta - 1)!}
  ,
\end{align}
$$

where $B$ is the [beta function](https://en.wikipedia.org/wiki/Gamma_function) and $\Gamma$ is the [gamma function](https://en.wikipedia.org/wiki/Gamma_function).

I'm not sure how the above integral is so useful for this exercise since calculating the mean and variance only require $n = 0$ and $m = 1, 2$.

The mean of $Z$ is the above expectation when $m = 1$ and $n = 0$, giving

$$
\mathbb E (Z)
=
\frac{(\alpha + \beta - 1)!}{(\alpha - 1)! (\beta - 1)!}
\frac{\alpha! (\beta - 1)!}{(\alpha + \beta)!}
=
\frac{\alpha}{\alpha + \beta}
.
$$

The second moment is given by $m = 2$ and $n = 0$, which is

$$
\mathbb E(Z^2)
=
\frac{(\alpha + \beta - 1)!}{(\alpha - 1)! (\beta - 1)!}
\frac{(\alpha +1)! (\beta - 1)!}{(\alpha + \beta + 1)!}
=
\frac{(\alpha + 1) \alpha}{(\alpha + \beta + 1) (\alpha + \beta)}
.
$$

It follows that the variance is

\begin{align}
  \mathbb E (Z^2) - \mathbb E (Z)^2
  &=
  \frac{(\alpha + 1) \alpha}{(\alpha + \beta + 1) (\alpha + \beta)}
  -
  \frac{\alpha^2}{(\alpha + \beta)^2}
  
  \\
  &=
  
  \frac{(\alpha + 1) \alpha (\alpha + \beta)}{(\alpha + \beta + 1) (\alpha + \beta)^2}
  -
  \frac{\alpha^2(\alpha + \beta + 1)}{(\alpha + \beta + 1) (\alpha + \beta)^2}
  
  \\
  &=
  
  \frac{
    \alpha^2 (\alpha + \beta) + \alpha (\alpha + \beta)
    -
    \alpha^2(\alpha + \beta) - \alpha^2
  }{(\alpha + \beta + 1) (\alpha + \beta)^2}
  
  \\
  &=
  
  \frac{
    \alpha (\alpha + \beta)
    -
    \alpha^2
  }{(\alpha + \beta + 1) (\alpha + \beta)^2}
  \\
  &=
  
  \frac{
    \alpha \beta
  }{(\alpha + \beta + 1) (\alpha + \beta)^2}
  .
\end{align}
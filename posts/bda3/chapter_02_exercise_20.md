---
always_allow_html: True
author: Brian Callander
date: '2018-09-08'
output:
  md_document:
    preserve_yaml: True
    variant: markdown
tags: |
    bda chapter 2, solutions, bayes, exponential, gamma, truncated
    observations, posterior variance
title: BDA3 Chapter 2 Exercise 20
---

Here's my solution to exercise 20, chapter 2, of
[Gelman's](https://andrewgelman.com/) *Bayesian Data Analysis* (BDA),
3rd edition. There are
[solutions](http://www.stat.columbia.edu/~gelman/book/solutions.pdf) to
some of the exercises on the [book's
webpage](http://www.stat.columbia.edu/~gelman/book/).

<!--more-->
<div style="display:none">

$\DeclareMathOperator{\dbinomial}{Binomial}  \DeclareMathOperator{\dbern}{Bernoulli}  \DeclareMathOperator{\dpois}{Poisson}  \DeclareMathOperator{\dnorm}{Normal}  \DeclareMathOperator{\dcauchy}{Cauchy}  \DeclareMathOperator{\dexponential}{Exp}  \DeclareMathOperator{\dgamma}{Gamma}  \DeclareMathOperator{\dinvgamma}{InvGamma}  \DeclareMathOperator{\invlogit}{InvLogit}  \DeclareMathOperator{\logit}{Logit}  \DeclareMathOperator{\dbeta}{Beta}$

</div>

Suppose $y \mid \theta \sim \dexponential(\theta)$ with prior
$\theta \sim \dgamma(\alpha, \beta)$. If we observe that $y \ge 100$,
then the posterior is

$$
\begin{align}
  p(\theta \mid y \ge 100)
  &\propto
  \theta^{\alpha - 1} e^{-\beta \theta}
  \int_{y = 100}^\infty \theta e^{-\theta y} dy
  \\
  &=
  \theta^{\alpha - 1} e^{-\beta \theta}
  \left[ (-1) e^{-\theta y}  \right]_{100}^\infty
  \\
  &=
  \theta^{\alpha - 1} e^{-\beta \theta}
  e^{-100\theta}
  \\
  &=
  \theta^{\alpha - 1} e^{-(\beta + 100) \theta}
  ,
\end{align}
$$

which is a $\dgamma(\alpha, \beta + 100)$ distribution. The posterior
mean is $\frac{\alpha}{\beta + 100}$ and the posterior variance is
$\frac{\alpha}{(\beta + 100)^2}$.

If instead we had observed $y = 100$, the posterior would have been

$$
\begin{align}
  p(\theta \mid y = 100)
  &\propto
  \theta^{\alpha - 1} e^{-\beta \theta}
  \theta e^{-\theta 100} 
  \\
  &=
  \theta^{\alpha} e^{-(\beta + 100) \theta}
  ,
\end{align}
$$

which is a $\dgamma(\alpha + 1, \beta + 100)$ distribution. The
posterior mean here is $\frac{\alpha + 1}{\beta + 100}$ and the
posterior variance is $\frac{\alpha + 1}{(\beta + 100)^2}$.

Both of these estimates are greater than in the case of observing
$y \ge 100$. This is surprising because knowing that $y = 100$ is more
informative than just knowing $y \ge 100$. The reason there is actually
less variance when $y \ge 100$ is that we get to average over all
possibilities of $y \ge 100$, and the case $y = 100$ has the greatest
variance of all these possibilities.

We can illustrate this idea more formally using identity (2.8). In the
context of this exercise, the identity can be written

$$
\mathbb V \left(\theta \mid y \ge 100 \right)
\ge
\mathbb E \left( \mathbb V \left(\theta \mid y \right) \mid y \ge 100 \right)
,
$$

where all the probabilities are now conditional on $y \ge 100$. The left
hand side is the posterior variance given $y \ge 100$, which we
calculated above to be $\frac{\alpha}{(\beta + 100)^2}$. The quantity
$\mathbb E ( \mathbb V (\theta \mid y = 100) \mid y \ge 100)$ is just
$\frac{\alpha + 1}{(\beta + 100)^2}$ as shown above, which is greater
than the LHS. However, this quantity is fundamentally different to what
the right hand side of the identity expresses. The RHS actually
evaluates to

$$
\int_{100}^\infty \frac{\alpha}{(\beta + \tilde y)^2} p(\tilde y \mid y \ge 100) d\tilde y.
$$

That is, it averages over all possible realisations of the variance
given $y \ge 100$. The inequality only guarantees that the posterior
variance is *on average* smaller than the prior variance, so we can't
just plug in one value of interest.

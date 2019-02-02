---
always_allow_html: True
author: Brian Callander
date: 2019-02-02
output:
  md_document:
    preserve_yaml: True
    variant: markdown
tags: bda chapter 3, solutions, conjugate prior, normal, multivariate, quadratic form
tldr: Here's my solution to exercise 13, chapter 3, of Gelman's Bayesian Data Analysis (BDA), 3rd edition.
title: BDA3 Chapter 3 Exercise 13
---

Here's my solution to exercise 13, chapter 3, of
[Gelman's](https://andrewgelman.com/) *Bayesian Data Analysis* (BDA),
3rd edition. There are
[solutions](http://www.stat.columbia.edu/~gelman/book/solutions.pdf) to
some of the exercises on the [book's
webpage](http://www.stat.columbia.edu/~gelman/book/).

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
  \DeclareMathOperator{\dinvchi}{InvChi2}
  \DeclareMathOperator{\dnorminvchi}{NormInvChi2}
  \DeclareMathOperator{\logit}{Logit}
  \DeclareMathOperator{\ddirichlet}{Dirichlet}
  \DeclareMathOperator{\dbeta}{Beta}$

</div>

Suppose we have likelihood $y_i \mid \mu \sim \dnorm(\mu, \Sigma)$ and prior $\mu \sim \dnorm(\mu_0, \Lambda_0)$, where the distributions are multivariate in each case. This is the multivariate analogue of [question 9](./chapter_03_exercise_09.html), where we found that the [quadratic form solution](./quadratic_forms.html) was simpler. The quadratic forms of the log-likelihoods and log-prior are

$$
\begin{align}
  Q_i(\mu)
  &=
  (y_i - \mu)^T \Sigma^{-1} (y_i - \mu)
  \\
  Q_0(\mu)
  &=
  (\mu_0 - \mu)^T \Lambda_0^{-1} (\mu_0 - \mu)
  .
\end{align}
$$

The quadratic form of the full log-likelihood is thus $Q_1^n := \sum_{i = 1}^n Q_i$, given by

$$
\begin{align}
  Q_1^n(\mu)
  &=
  (a_1^n - \mu)^T \left( n \Sigma^{-1} \right) (a_1^n - \mu) + c_1^n
  \\
  a_1^n
  &=
  \left( n\Sigma^{-1} \right)^{-1}
  \sum_{i = 1}^n \Sigma^{-1} y_i 
  \\
  &=
  \left( n\Sigma^{-1} \right)^{-1}
  \left( n\Sigma^{-1} \bar y \right)
  ,
\end{align}
$$

where $c_1^n$ is constant and can thus be ignored. The expression for $a_1^n$ can easily be proved by induction. Indeed, for $n = 1$ we have $a_1^1 = y_1$. In the induction step, we can assume $a_1^{n - 1} = \left( (n - 1)\Sigma^{-1} \right)^{-1} \left( \Sigma^{-1} \sum_1^{n-1} y_i \right)$. Then we have

$$
\begin{align}
  a_1^n
  &=
  \left( (n - 1)\Sigma^{-1} + \Sigma^{-1} \right)^{-1}
  \left( \Sigma^{-1} \sum_{i = 1}^{n-1} y_i + \Sigma^{-1} y_n \right)
  \\
  &=
  \left( n\Sigma^{-1} \right)^{-1}
  \left( \Sigma^{-1} \sum_{i = 1}^{n} y_i \right)
  \\
  &=
  \left( n\Sigma^{-1} \right)^{-1}
  \left( n\Sigma^{-1} \bar y \right)
  .
\end{align}
$$

The quadratic form of the log-posterior is then $Q = Q_0 + Q_1^n$, given by

$$
\begin{align}
  Q(\mu)
  &=
  (\mu_n - \mu)^T \Lambda_n^{-1} (\mu_n - \mu) + c
  \\
  \Lambda_n^{-1} 
  &=
  \lambda_0^{-1} + n\Sigma^{-1}
  \\
  \mu_n 
  &=
  \left( \Lambda_0^{-1} + n\Sigma^{-1} \right)
  \left( \lambda_0^{-1}\mu_0 + n\Sigma^{-1} \bar y \right)
  ,
\end{align}
$$

where $c$ is constant and can be dropped.
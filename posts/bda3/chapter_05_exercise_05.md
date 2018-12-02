---
title: BDA3 Chapter 5 Exercise 5
author: Brian Callander
tags: bda chapter 5, solutions, bayes, de finetti, exchangeability, covariance
tldr: Here's my solution to exercise 5, chapter 5, of Gelman's Bayesian Data Analysis (BDA), 3rd edition.
date: 2018-11-10
always_allow_html: True
output:
  md_document:
    preserve_yaml: True
    variant: markdown
---

Here's my solution to exercise 5, chapter 5, of
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
\DeclareMathOperator{\dsinvchi}{SInvChi2}  
\DeclareMathOperator{\dchi}{Chi2}  
\DeclareMathOperator{\dnorminvchi}{NormInvChi2}  
\DeclareMathOperator{\logit}{Logit}  
\DeclareMathOperator{\ddirichlet}{Dirichlet}  
\DeclareMathOperator{\dbeta}{Beta}
\DeclareMathOperator{\cov}{Cov} 
\DeclareMathOperator{\var}{Var}$

</div>

Suppose the joint distribution for parameters
$\theta = (\theta_1, \dotsc, \theta_J)$ can be written as a mixture of
iid parameters

$$
p(\theta)
=
\int \prod_1^J p(\theta_j \mid \phi) p(\phi) d\phi
.
$$

We'd like to show that the pairwise covariance is always non-negative.
Since the parameters $\theta$ are exchangeable, it is sufficient to show
that $\theta_1, \theta_2$ have non-negative covariance. Using the [law
of total
covariance](https://en.wikipedia.org/wiki/Law_of_total_covariance), the
fact that independent variables have zero covariance, and the fact that
exchangeable variables have the same expectation, it follows that

$$
\begin{align}
  \cov(\theta_1, \theta_2)
  &=
  \mathbb E (\cov(\theta_1, \theta_2 \mid \phi)) + \cov(\mathbb E (\theta_1 \mid \phi), \mathbb E(\theta_2 \mid \phi))
  \\
  &=
  0 + \mathbb E \left( \cov \left( \theta_1 \mid \phi, \theta_2 \mid \phi \right) \right)
  \\
  &=
  \mathbb E \left( \mathbb E(\theta_1 \mid \phi) \mathbb E(\theta_2 \mid \phi) \right)
  - 
  \mathbb E\left( \mathbb E(\theta_1 \mid \phi) \right) \mathbb E \left( \mathbb E(\theta_2 \mid \phi) \right)
  \\
  &=
  \mathbb E \left( \mathbb E(\theta_1 \mid \phi)^2 \right)
  -
  \left( \mathbb E \mathbb E (\theta_1 \mid \phi) \right)^2
  \\
  &=
  \var(\mathbb E(\theta_1 \mid \phi))
  \\
  &
  \ge
  0
  .
\end{align}
$$

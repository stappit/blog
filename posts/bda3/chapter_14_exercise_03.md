---
title: "BDA3 Chapter 14 Exercise 3"
author: "Brian Callander"
date: "2019-02-10"
tags: bda chapter 14, solutions, quadratic form, qr decomposition
tldr: "Here's my solution to exercise 3, chapter 14, of Gelman's Bayesian Data Analysis (BDA), 3rd edition."
always_allow_html: yes
output: 
  md_document:
    variant: markdown
    preserve_yaml: yes
---

Here's my solution to exercise 3, chapter 14, of [Gelman's](https://andrewgelman.com/) *Bayesian Data Analysis* (BDA), 3rd edition. There are [solutions](http://www.stat.columbia.edu/~gelman/book/solutions.pdf) to some of the exercises on the [book's webpage](http://www.stat.columbia.edu/~gelman/book/).

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

We need to reexpress $(y - X\beta)^T (y - X\beta)$ as $(\mu - \beta)^T \Sigma^{-1} (\mu - \beta)$, for some $\mu$, $\Sigma$. Using the [QR-decomposition](https://en.wikipedia.org/wiki/QR_decomposition) of $X = QR$, we see

$$
\begin{align}
  (y - X\beta)^T(y - X\beta)
  &=
  (Q^T(y - X\beta))^TQ^T(y - X\beta)
  \\
  &=
  (Q^Ty - Q^TX\beta)^T (Q^Ty - Q^TX\beta)
  \\
  &=
  (Q^Ty - R\beta)^T (Q^Ty - R\beta)
  ,
\end{align}
$$

where $Q$ is [orthogonal](https://en.wikipedia.org/wiki/Orthogonal_matrix) and $R$ an invertible [upper triangular matrix](https://en.wikipedia.org/wiki/Triangular_matrix). We can read of the minimum of this quadratic form as

$$
\hat\beta
=
R^{-1}Q^Ty
,
$$

which shows that $\mu = \hat\beta = R^{-1}Q^Ty$. Note that

$$
\begin{align}
  (X^TX)^{-1}X^T
  &=
  (R^TR)^{-1}R^T Q^T
  \\
  &=
  R^{-1}R^{-T}R^T Q^T
  \\
  &=
  R^{-1}Q^T
\end{align}
$$

so that $\hat\beta = (X^TX)^{-1}X^Ty$.

Expanding the brackets of both quadratic form expressions and comparing the quadratic coefficients, we see that

$$
\Sigma^{-1} = R^T R = X^T X
,
$$

which shows that $V_\beta = (X^T X)^{-1}$, in the notation of page 355.

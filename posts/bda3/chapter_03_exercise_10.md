---
title: BDA3 Chapter 3 Exercise 10
author: Brian Callander
date: 2018-10-21
tags: bda chapter 3, solutions, bayes, f, scaled inverse chi2, inverse chi2, chi2
tldr: Here's my solution to exercise 10, chapter 3, of Gelman's Bayesian Data Analysis (BDA), 3rd edition.
always_allow_html: True
output:
  md_document:
    preserve_yaml: True
    variant: markdown
---

Here's my solution to exercise 10, chapter 3, of
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
  \DeclareMathOperator{\dbeta}{Beta}$

</div>

For $j = 1, 2$, let

$$
\begin{align}
y_j \mid \mu_j \sigma_j^2 
&\sim
\dnorm(\mu_j, \sigma_j^2)
\\
p(\mu_j, \log \sigma_j^2)
&\propto
1.
\end{align}
$$

We show that 

$$
\frac{s_1^2 \sigma_2^2}{s_2^2 \sigma_1^2}
\sim
F(n_1 - 1, n_2 - 1)
.
$$

Equation 3.5 in the book shows that $\sigma_j^2 \mid y \sim \dinvchi(n_j - 1, s_j^2)$. It follows that $\frac{\sigma_j^2}{(n_j - 1) s_j^2} \sim \dinvChi(n_j - 1)$. Thus, $\frac{(n_j - 1) s_j^2}{\sigma_j^2} \sim \dchi(n_j - 1)$. The result follows from [the fact](https://en.wikipedia.org/wiki/F-distribution#Characterization) that the ratio of two $\chi^2$ random variables (divided by the ratio of their degrees of freedom) has an $F$-distribution.

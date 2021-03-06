---
always_allow_html: True
author: Brian Callander
date: '2018-10-21'
output:
  md_document:
    preserve_yaml: True
    variant: markdown
tags: 'bda chapter 3, solutions, bayes, poisson, binomial, unsolved'
title: BDA3 Chapter 3 Exercise 7
tldr: |
    Here's my solution to exercise 7, chapter 3, of Gelman's Bayesian Data
    Analysis (BDA), 3rd edition.
---

Here's my solution to exercise 7, chapter 3, of
[Gelman's](https://andrewgelman.com/) *Bayesian Data Analysis* (BDA),
3rd edition. There are
[solutions](http://www.stat.columbia.edu/~gelman/book/solutions.pdf) to
some of the exercises on the [book's
webpage](http://www.stat.columbia.edu/~gelman/book/).

<!--more-->
<div style="display:none">

$\DeclareMathOperator{\dbinomial}{Binomial}  \DeclareMathOperator{\dbern}{Bernoulli}  \DeclareMathOperator{\dpois}{Poisson}  \DeclareMathOperator{\dnorm}{Normal}  \DeclareMathOperator{\dt}{t}  \DeclareMathOperator{\dcauchy}{Cauchy}  \DeclareMathOperator{\dexponential}{Exp}  \DeclareMathOperator{\duniform}{Uniform}  \DeclareMathOperator{\dgamma}{Gamma}  \DeclareMathOperator{\dinvgamma}{InvGamma}  \DeclareMathOperator{\invlogit}{InvLogit}  \DeclareMathOperator{\logit}{Logit}  \DeclareMathOperator{\ddirichlet}{Dirichlet}  \DeclareMathOperator{\dbeta}{Beta}$

</div>

Suppose we observe $b$ bikes and $v$ other vehicles passing a section of
road within an hour. We can model the counts as Poisson distributed

$$
\begin{align}
  b \mid \theta_b &\sim \dpois(\theta_b)
  \\
  v \mid \theta_v &\sim \dpois(\theta_v)
\end{align}
$$

or as binomial distributed

$$
\begin{align}
  b \mid n, p &\sim \dbinomial(n, p)
\end{align}
$$

where $n$ is the number of trials and $p$ is the probability of
observing a bike. Let

$$
p := \frac{\theta_b}{\theta_b + \theta_v}
.
$$

We are supposed to show that this definition of $p$ gives the two models
the same likelihood, but I'm stuck. At best I can show that the
expectations are different

$$
\mathbb E (b \mid \theta_b) = \theta_b
\\
\mathbb E (b \mid n, p) = np = n\frac{\theta_b}{\theta_b + \theta_v}
$$

which suggests the conditioning should be done differently.

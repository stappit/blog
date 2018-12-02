---
title: BDA3 Chapter 5 Exercise 1
author: Brian Callander
date: 2018-11-05
tags: bda chapter 5, solutions, bayes, exchangeability
tldr: Here's my solution to exercise 1, chapter 5, of Gelman's Bayesian Data Analysis (BDA), 3rd edition.
always_allow_html: True
output:
  md_document:
    preserve_yaml: True
    variant: markdown
---

Here's my solution to exercise 1, chapter 5, of
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

Suppose we have a box with one black ball and one white ball inside. We picka ball $y_1$ at random, put it back, then pick another ball $y_2$ at random. Then $y_1$ and $y_2$ are independent, and therefore also exchangeable.

The draws are no longer independent if we don't put the first ball back before picking the second ball. They remain exchangeable since the joint probability only depends on the equality of the arguments, not on their order. More specifically,

$$
  p(y_1, y_2)
  =
  \begin{cases}
    \frac{1}{2} & \text{ if } y_1 \ne y_2 \\
    0 & \text{ otherwise.}
  \end{cases}
$$

Treating the draws as if they were independent would not be a good idea.

If there were $M$ balls of each colour, where $M \gg 0$ such as $M = 10^6$, then the draws would still not be independent, but they would be very close to independence. They remain exchangeable. This is clearer from the joint probability function

$$
  p(y_1, y_2)
  =
  \begin{cases}
    \frac{1}{2}\frac{M}{2M - 1} & \text{ if } y_1 \ne y_2 \\
    \frac{1}{2}\frac{M - 1}{2M - 1} & \text{ otherwise,}
  \end{cases}
$$

since $\frac{M}{2M - 1} \approx \frac{1}{2} \approx \frac{M - 1}{2M - 1}$ for $M \gg 0$.

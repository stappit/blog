---
title: BDA3 Chapter 5 Exercise 2
author: Brian Callander
date: 2018-11-05
tags: bda chapter 5, solutions, bayes, exchangeability
tldr: Here's my solution to exercise 2, chapter 5, of Gelman's Bayesian Data Analysis (BDA), 3rd edition.
always_allow_html: True
output:
  md_document:
    preserve_yaml: True
    variant: markdown
---

Here's my solution to exercise 2, chapter 5, of
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

This exercise is an extension of [the previous exercise](./chapter_05_exercise_01.html). Suppose we have a box with $n$ balls, with $B$ black balls and $W$ white balls ($n = B + W$), where we don't know how many of each. We pick a ball $y_1$ at random, put it back, then pick another ball $y_2$ at random. In this case, Then $y_1$ and $y_2$ are independent, and therefore also exchangeable.

The draws are no longer independent if we don't put the first ball back before picking the second ball. They remain exchangeable since the conditional joint probability function does not depend on the order

$$
  p(y_1, y_2 \mid B, W)
  =
  \begin{cases}
    \frac{BW}{n(n - 1)} & \text{ if } y_1 \ne y_2 \\
    \frac{W(W - 1)}{n (n - 1)} & \text{ if } y_1 = y_2 = \text{white} \\
    \frac{B(B - 1)}{n (n - 1)} & \text{ if } y_1 = y_2 = \text{black,} 
  \end{cases}
$$

which implies that the joint probability does not depend on the order

$$
  p(y_1, y_2)
  =
  \sum_{B + W \ge 2 \\ B \cdot W > 0}^\infty p(y_1, y_2 \mid B, W) p(B, W)
  .
$$

Whether we can treat them as if they were independent depends on the prior $p(B, W)$. If there is significant probability mass on low values, then we shouldn't treat them as independent (see [the previous exercise](./chapter_05_exercise_01.html)). If the only significant probability mass were on very large values of $B$ and $W$, then we could treat them as if they were independent. This follows from the fact that 

$$
\begin{align}
  \frac{B-1}{n - 1} 
  &\approx
  \frac{B}{n}
  \approx
  \frac{B}{n-1}
  \\
  \frac{W-1}{n - 1} 
  &\approx
  \frac{W}{n}
  \approx
  \frac{W}{n-1}
  ,
\end{align}
$$

when $B, W \gg 0$.
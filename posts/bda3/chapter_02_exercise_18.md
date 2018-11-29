---
title: "BDA3 Chapter 2 Exercise 18"
author: "Brian Callander"
date: '2018-09-08'
tags: bda chapter 2, solutions, bayes, gamma, poisson, conjugate prior
---

Here's my solution to exercise 18, chapter 2, of [Gelman's](https://andrewgelman.com/) *Bayesian Data Analysis* (BDA), 3rd edition. There are [solutions](http://www.stat.columbia.edu/~gelman/book/solutions.pdf) to some of the exercises on the [book's webpage](http://www.stat.columbia.edu/~gelman/book/).

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

Suppose we have $n$ observations from a Poisson likelihood, $y_i \mid \theta \sim \dpois(x_i\theta)$,  with rate $\theta$ and exposure $x_i$. We show that with a gamma prior, $\theta \sim \dgamma(\alpha, \beta)$, the posterior also has a gamma distribution. 

As shown in the book, the likelihood and prior are

$$
\begin{align}
p (y \mid \theta)
&\propto
\theta^{\sum_1^n y_i} e^{-\theta \sum_i^n x_i}
\\
p(\theta)
&\propto
\theta^{\alpha - 1} e^{-\beta \theta}
.
\end{align}
$$

Thus the posterior is

$$
\begin{align}
p (\theta \mid y)
&\propto
\theta^{\sum_1^n y_i} e^{-\theta \sum_i^n x_i}
\cdot
\theta^{\alpha - 1} e^{-\beta \theta}
\\
&=
\theta^{\alpha - 1 + \sum_1^n y_i}
e^{-\theta \left( \beta + \sum_1^n x_i \right)}
,
\end{align}
$$

which shows that $p(\theta \mid y) \sim \dgamma(\alpha + \sum_1^n y_i, \beta + \sum_1^n x_i)$.
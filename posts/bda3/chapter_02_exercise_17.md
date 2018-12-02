---
title: "BDA3 Chapter 2 Exercise 17"
author: "Brian Callander"
date: '2018-09-08'
tags: bda chapter 2, solutions, bayes, chi2, highest posterior interval
tldr: Here's my solution to exercise 17, chapter 2, of Gelman's Bayesian Data Analysis (BDA), 3rd edition.
---

Here's my solution to exercise 17, chapter 2, of [Gelman's](https://andrewgelman.com/) *Bayesian Data Analysis* (BDA), 3rd edition. There are [solutions](http://www.stat.columbia.edu/~gelman/book/solutions.pdf) to some of the exercises on the [book's webpage](http://www.stat.columbia.edu/~gelman/book/).

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

We'll show that highest posterior invervals are not invariant under parameter transformations.

Suppose $\frac{nv}{\sigma^2} \mid \sigma^2 \sim \chi_n^2$ with (improper) prior $\sigma \propto \sigma^{-1}$. From equation (2.19), page 52, the prior density for $\sigma^2$ is 

$$
p(\sigma^2) 
=
p(\sigma) (2\sigma)^{-1}
\propto
\frac{1}{\sigma^2}
.
$$

Thus the posteriors are

$$
\begin{align}
  p(\sigma^2 \mid y) 
  &=
  \left( \frac{1}{\sigma} \right)^n e^{\frac{-nv}{2 \sigma^2}}
  \\
  p(\sigma \mid y) 
  &=
  \left( \frac{1}{\sigma} \right)^{n - 1} e^{\frac{-nv}{2 \sigma^2}}
  ,
\end{align}
$$

where we have dropped any multiplicative constants that don't depend on $\sigma$.

Since the posteriors are continuous everywhere, we can assume that the highest posterior regions are collections of closed intervals. Let $a, b$ be two boundary points on the highest posterior density region of $p(\sigma^2 \mid y)$.  Using continuity and the defining property of highest posterior regions, the density at $a$ is equal to the density at $b$, i.e.

$$
\left( \frac{1}{a} \right)^n e^{\frac{-nv}{2 a^2}}
=
\left( \frac{1}{b} \right)^n e^{\frac{-nv}{2 b^2}}
.
$$

Assume for contradiction that the highest posterior region for $p(\sigma \mid y)$ is the square root of the region for $p(\sigma^2 \mid y)$.  Then by continuity, $\sqrt{a}, \sqrt{b}$ are endpoints on the highest posterior region for $p(\sigma \mid y)$. Thus

$$
\left( \frac{1}{a} \right)^{n - 1} e^{\frac{-nv}{2 a^2}}
=
\left( \frac{1}{b} \right)^{n - 1} e^{\frac{-nv}{2 b^2}}
.
$$


The two equalities above are equivalent to $\frac{1}{a} = \frac{1}{b}$, which implies

$$
a = b
\qquad
↯
$$

This is true of any two boundary points, so the highest posterior region is a point. This contradicts the fact that the highest posterior region contains 95% probability mass. Therefore, the highest posterior regions are not invariant under reparameterisation.
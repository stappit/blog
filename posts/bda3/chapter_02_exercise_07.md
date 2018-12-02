---
always_allow_html: True
author: Brian Callander
date: '2018-08-26'
output:
  md_document:
    preserve_yaml: True
    variant: markdown
tags: |
    bda chapter 2, bda, solutions, bayes, binomial, natural parameter,
    exponential family, improper prior
title: BDA3 Chapter 2 Exercise 7
tldr: |
    Here's my solution to exercise 7, chapter 2, of Gelman's Bayesian Data
    Analysis (BDA), 3rd edition.
---

Here's my solution to exercise 7, chapter 2, of
[Gelman's](https://andrewgelman.com/) *Bayesian Data Analysis* (BDA),
3rd edition. There are
[solutions](http://www.stat.columbia.edu/~gelman/book/solutions.pdf) to
some of the exercises on the [book's
webpage](http://www.stat.columbia.edu/~gelman/book/).

<!--more-->
<div style="display:none">

$\DeclareMathOperator{\dbinomial}{binomial}  \DeclareMathOperator{\dbern}{Bernoulli}  \DeclareMathOperator{\dgamma}{gamma}  \DeclareMathOperator{\invlogit}{invlogit}  \DeclareMathOperator{\logit}{logit}  \DeclareMathOperator{\dbeta}{beta}$

</div>

We show that a uniform prior on the natural parameter of a binomial
model implies an improper prior under a different parameterisation.

The binomial likelihood can be written as a member of the exponential
family as

$$
\begin{align}
  \dbinomial(y \mid \theta)
  &=
  \binom{n}{y} \theta^y (1 - \theta)^{n - y}
  \\
  &=
  \binom{n}{y} \cdot (1 - \theta)^n \cdot \exp \left(y \log \left(\frac{\theta}{1 - \theta}\right)\right)
  \\
  &=
  f(y) \cdot g(\theta) \cdot \exp (\phi(\theta) \cdot u(y))
  ,
\end{align}
$$

where $\phi(\theta) := \log \frac{\theta}{1 - \theta}$, $u(y) := y$,
$g(\theta) := (1 - \theta)^n$. Suppose the natural parameter
$\phi \sim \dbeta(1, 1)$ is uniformly distributed. Then the distribution
of $\theta$ is

$$
\begin{align}
  p(\theta) 
  &\propto
  p(\phi) \cdot \vert \invlogit^\prime (\phi) \vert^{-1}
  \\
  &=
  \left \vert \frac{1}{1 + \exp(-\phi)}^\prime \right\vert^{-1}
  \\
  &=
  \left \vert \frac{1}{\left(1 + \exp(-\phi)\right)^2} \cdot \exp(-\phi) \right\vert^{-1}
  \\
  &=
  \frac{1 + 2 \exp(-\phi) + \exp(-2\phi)}{\exp(-\phi)}
  \\
  &=
  \exp(\phi) + 2 + \exp(-\phi)
  \\
  &=
  \frac{\theta}{1 - \theta} + 2 + \frac{1 - \theta}{\theta}
  \\
  &=
  \frac{\theta^2 + 2\theta(1 - \theta) + (1 - \theta)^2}{\theta(1 - \theta)}
  \\
  &=
  \frac{1}{\theta(1 - \theta)}
  \\
  &=
  \theta^{-1}(1 - \theta)^{-1}
  \qquad \square
\end{align}
$$

This is an improper distribution on $\theta$ because

$$
\begin{align}
  \int_0^1 \frac{1}{\theta(1 - \theta)}
  &\ge
  \int_0^1 \frac{1}{\theta}
  \\
  &=
  \log\theta \vert_0^1
  \\
  &=
  \infty.
\end{align}
$$

When $y = 0$, then the posterior distribution is
$p(\theta \mid y = 0) \propto (1 - \theta)^{n - 1}\theta^{-1}$. When
$y = n$, then the posterior distribution is
$p(\theta \mid y = n) \propto \theta^{n-1}(1 - \theta)^{-1}$. These two
cases are equivalent by the change of variable
$\theta \mapsto 1 - \theta$.

We show that the distribution is improper for $y = 0$ by induction. The
case $n = 0$ is shown above (for the prior). Assume the distribution is
improper for any integer $k < n$. Then using integration by parts yields

$$
\begin{align}
\int_0^1 \theta^{- 1}(1 - \theta)^{n - 1} d\theta
&=
\int_0^1 \theta^{- 1}(1 - \theta)^{n - 2} \cdot (1 - \theta)d\theta
\\
&=
\left[(1 - \theta)^{n-2}(1 - \frac{\theta}{2}) \right]_0^1
+
\int_0^1 \frac{(1 - \theta)^{n - 2}}{\theta}
+
(n-2)(1 - \theta)^{n-3}
-
\frac{(1 - \theta)^{n-2}}{2}
-
(n - 2)\theta\frac{(1 - \theta)^{n-3}}{2}
d\theta
\\
&=
c
+
\int_0^1 \frac{(1 - \theta)^{n - 2}}{\theta} d\theta,
\end{align}
$$

where $c < \infty$. By the induction hypothesis, the integral on the
last line is $\infty$. Therefore, the distribution is also improper for
$n$.

---
title: "BDA3 Chapter 2 Exercise 14"
author: "Brian Callander"
date: '2018-09-03'
tags: bda chapter 2, solutions, bayes, normal, conjugate prior
---

Here's my solution to exercise 14, chapter 2, of [Gelman's](https://andrewgelman.com/) *Bayesian Data Analysis* (BDA), 3rd edition. There are [solutions](http://www.stat.columbia.edu/~gelman/book/solutions.pdf) to some of the exercises on the [book's webpage](http://www.stat.columbia.edu/~gelman/book/).

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

Suppose we have a normal prior $\theta \sim \dnorm (\mu_0, \frac{1}{\tau_0})$ and a normal sampling distribution $y \mid \theta \sim \dnorm(\theta, \sigma)$, where the variance is known. We will show by induction that the posterior is $\theta \mid y_1, \dotsc, y_{n} \sim \dnorm(\mu_{n}, \frac{1}{\tau_{n}})$ where

$$
  \frac{1}{\tau_{n}^2} = \frac{1}{\tau_0^2} + \frac{n}{\sigma^2}
  \quad
  \text{and}
  \quad
  \mu_n = \frac{\frac{1}{\tau_0^2}\mu_0 + \frac{n}{\sigma^2}\bar y_n}{\frac{1}{\tau_0^2} + \frac{n}{\sigma^2}}
$$

for $n = 1, \dotsc, \infty$.

## Base case

The case $n = 1$ can be reexpressed as

$$
\begin{align}
  \frac{1}{\tau_1^2} = \frac{\sigma^2 + \tau_0^2}{\sigma^2\tau_0^2}
  \quad
  \text{and}
  \quad
  \mu_1 = \frac{\sigma_0^2\mu_0 + \tau_0^2y}{\sigma^2 + \tau_0^2}
  .
\end{align}
$$

Now we can combine the fractions in the exponent, expand the brackets, collect the terms as $\theta$-coefficients, rewrite the coefficients in terms of $\mu_1$ and $\tau_1$, then complete the square in terms of $\theta$:

\begin{align}
  \frac{(y - \theta)^2}{\sigma^2}
  +
  \frac{(\theta - \mu_0)^2}{\tau_0^2}
  
  &=
  \frac{(y^2 + \theta^2 - 2\theta y) \tau_0^2 + (\theta^2 + \mu_0^2 - 2 \theta \mu_0) \sigma^2}{\sigma^2 \tau_0^2}
  
  \\
  &=
  \frac{\theta^2 (\tau_0^2 + \sigma^2) -2 \theta (\sigma^2\mu_0 + \tau_0^2y) + (y^2\tau_0^2 + \mu_0^2\sigma^2)}{\sigma^2\tau_0^2}
  \\
  &=
  \frac{\theta^2 (\tau_0^2 + \sigma^2) -2 \theta \mu_1 (\sigma^2 + \tau_0^2) + \mu_1 (\sigma^2 + \tau_0^2) }{\sigma^2\tau_0^2}
  \\
  &=
  \theta^2\frac{1}{\tau_1^2} -2\theta \mu_1 \frac{1}{\tau_1^2} + \mu_1 \frac{1}{\tau_1^2}
  \\
  &=
  \frac{\theta^2 -2 \mu_1 \theta + \mu_1^2}{\tau_1^2} 
  \\
  &=
  \frac{(\theta - \mu_1)^2}{\tau_1^2} 
  .
\end{align}

## Induction step

The induction hypothesis is that the variance and mean are given by

$$
  \frac{1}{\tau_n^2} = \frac{1}{\tau_0^2} + \frac{n}{\sigma^2}
  \quad
  \text{and}
  \quad
  \mu_n = \frac{\frac{1}{\tau_0^2}\mu_0 + \frac{n}{\sigma^2}\bar y}{\frac{1}{\tau_0^2} + \frac{n}{\sigma^2}}
$$

for some $n \ge 1$.  

Starting with the variance, the base step can be reexpressed as

$$
\frac{1}{\tau_{n+1}^2} 
=
\frac{1}{\tau_n^2} + \frac{1}{\sigma^2}
.
$$

Now apply the induction hypothesis to get

$$
\frac{1}{\tau_{n+1}^2} 
=
\frac{1}{\tau_0^2} + \frac{n}{\sigma^2} + \frac{1}{\sigma^2}
=
\frac{1}{\tau_0^2} + \frac{n+1}{\sigma^2}
.
$$

For the mean we apply the same strategy. The base step can be reexpressed as

$$
\mu_{n+1}
=
\frac{
  \frac{1}{\tau_n^2}\mu_n + \frac{1}{\sigma^2}y_{n+1}
}{
  \frac{1}{\tau_n^2} + \frac{1}{\sigma^2}
}
.
$$

Applying the induction hypothesis then gives
  
\begin{align}
  \mu_{n+1}
  &=
  \frac{
    \frac{1}{\tau_n^2} \left( \frac{\frac{1}{\tau_0^2}\mu_0 + \frac{n}{\sigma^2}\bar y_n}{\frac{1}{\tau_0^2} + \frac{n}{\sigma^2}} \right) + \frac{1}{\sigma^2}y_{n+1}
  }{
    \frac{1}{\tau_0^2} + \frac{n+1}{\sigma^2}}
  
  \\
  &=
  \frac{
    \frac{1}{\tau_0^2}\mu_0 + \frac{n}{\sigma^2}\bar y_n + \frac{1}{\sigma^2}y_{n+1}
  }{
    \frac{1}{\tau_0^2} + \frac{n+1}{\sigma^2}
  }
  
  \\
  &=
  \frac{
    \frac{1}{\tau_0^2}\mu_0 + \frac{n+1}{\sigma^2}\bar y_{n+1}
  }{
    \frac{1}{\tau_0^2} + \frac{n+1}{\sigma^2}
  }
  ,
\end{align}

since

$$
\begin{align}
(n + 1) \bar y_{n + 1}
&:=
\sum_1^{n+1} y_i
\\
&=
y_{n+1} + \sum_1^n y_i
\\
&=
y_{n+1} + n\bar y_n
.
\end{align}
$$

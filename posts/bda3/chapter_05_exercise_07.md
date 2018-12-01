---
title: "BDA3 Chapter 5 Exercise 7"
author: "Brian Callander"
date: "2018-12-01"
tags: bda chapter 5, solutions, bayes, law of total expectation, law of total variance
always_allow_html: yes
output: 
  md_document:
    variant: markdown
    preserve_yaml: yes
---

Here's my solution to exercise 7, chapter 5, of [Gelman's](https://andrewgelman.com/) *Bayesian Data Analysis* (BDA), 3rd edition. There are [solutions](http://www.stat.columbia.edu/~gelman/book/solutions.pdf) to some of the exercises on the [book's webpage](http://www.stat.columbia.edu/~gelman/book/).

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

## Part a

Suppose $y \mid \theta \sim \dpois(\theta)$ with prior $\theta \sim \dgamma(\alpha, \beta)$. Let's derive the expectation and variance of $y$. Using equation 1.8 (page 21), the expectation is

$$
\begin{align}
  \mathbb E (y)
  &=
  \mathbb E \left( \mathbb E(y \mid \theta) \right)
  \\
  &=
  \mathbb E \left( \theta \right)
  \\
  &=
  \frac{\alpha}{\beta}
  .
\end{align}
$$

Using equation 1.9 (page 21), the variance is 

$$
\begin{align}
  \mathbb V (y)
  &=
  \mathbb E \left( \mathbb V (y \mid \theta) \right)
  +
  \mathbb V \left( \mathbb E (y \mid \theta) \right)
  \\
  &=
  \mathbb E \left( \theta \right)
  +
  \mathbb V (\theta)
  \\
  &=
  \frac{\alpha}{\beta}
  +
  \frac{\alpha}{\beta^2}
  \\
  &=
  \alpha \frac{1 + \beta}{\beta^2}
  .
\end{align}
$$


## Part b

Suppose $y \mid \mu, \sigma \sim \dnorm(\mu, \sigma)$ with prior $p(\mu, \sigma^2) \propto \sigma^{-2}$. Then the expectation of $\mu \mid y$ is

$$
\begin{align}
  \mathbb E \left( \mu \mid y \right)
  &=
  \mathbb E \left( \mathbb E (\mu \mid \sigma^2, y) \mid y \right)
  \\
  &=
  \mathbb E \left( \bar y \mid y \right)
  \\
  &=
  \bar y
  .
\end{align}
$$

For posterior expectations, we condition on the data, which allows us to treat $y$, $n$, and $s$ as constants. Since $\theta := \sqrt{n} (\mu - \bar y) / s$ is a linear function of $\mu$, its posterior expectation is zero. For this to hold, it is necessary that $n \ge 2$ for $s$ to be well-defined (to avoid division by zero). Moreover, the first identity implicitly assumes that the expectation $\mathbb E (u \mid y)$ is well-defined. Combining the calculation of $p(\mu \mid y)$ with [this proof](https://www.statlect.com/probability-distributions/student-t-distribution#hid5) shows that it is well-defined only when $n \ge 3$.

The posterior variance is 

$$
\begin{align}
  \mathbb V \left( \frac{\sqrt{n}}{s} (\mu - \bar y) \mid y \right)
  &=
  \mathbb E \left( \mathbb V \left(\frac{\sqrt{n}}{s} (\mu - \bar y) \mid \sigma^2, y \right) \mid y \right)
  +
  \mathbb V \left( \mathbb E \left(\frac{\sqrt{n}}{s} (\mu - \bar y) \mid \sigma^2, y \right) \mid y \right)
  \\
  &=
  \mathbb E \left( \frac{n}{s^2} \mathbb V \left( \mu \mid \sigma^2, y \right) \mid y \right)
  +
  \mathbb V \left( 0 \mid y \right)
  \\
  &=
  \mathbb E \left(\frac{n}{s^2} \frac{\sigma^2}{n} \mid y \right)
  +
  0
  \\
  &=
  \frac{n - 1}{n - 3}
  .
\end{align}
$$

Since $n - 3$ appears in the denominator, it is necessary that $n \ge 4$. Again, for the first identity to hold, it is implicitly assumed that the variance on the left hand side is finite. It [can be verified](https://www.statlect.com/probability-distributions/student-t-distribution#hid6) that the variance is finite for $n \ge 4$.

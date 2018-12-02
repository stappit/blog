---
title: "BDA3 Chapter 2 Exercise 19"
author: "Brian Callander"
date: '2018-09-08'
tags: bda chapter 2, solutions, bayes, gamma, exponential, conjugate prior
tldr: Here's my solution to exercise 19, chapter 2, of Gelman's Bayesian Data Analysis (BDA), 3rd edition.
---

Here's my solution to exercise 19, chapter 2, of [Gelman's](https://andrewgelman.com/) *Bayesian Data Analysis* (BDA), 3rd edition. There are [solutions](http://www.stat.columbia.edu/~gelman/book/solutions.pdf) to some of the exercises on the [book's webpage](http://www.stat.columbia.edu/~gelman/book/).

<!--more-->

<div style="display:none">
  $\DeclareMathOperator{\dbinomial}{Binomial}
   \DeclareMathOperator{\dbern}{Bernoulli}
   \DeclareMathOperator{\dpois}{Poisson}
   \DeclareMathOperator{\dnorm}{Normal}
   \DeclareMathOperator{\dcauchy}{Cauchy}
   \DeclareMathOperator{\dexponential}{Exp}
   \DeclareMathOperator{\dgamma}{Gamma}
   \DeclareMathOperator{\dinvgamma}{InvGamma}
   \DeclareMathOperator{\invlogit}{InvLogit}
   \DeclareMathOperator{\logit}{Logit}
   \DeclareMathOperator{\dbeta}{Beta}$
</div>

Let's show that the gamma distribution is conjugate to the exponential distribution. That is, we suppose $y \mid \theta \sim \dexponential(\theta)$ with prior $\theta \sim \dgamma(\alpha, \beta)$, and show that the posterior is also gamma distributed.

The posterior is 

$$
\begin{align}
  p(\theta \mid y)
  &\propto
  \theta^n e^{-\theta \sum_1^n y_i} \cdot \theta^{\alpha - 1} e^{-\beta \theta}
  \\
  &=
  \theta^{n + \alpha - 1} e^{-\theta \left(\beta + \sum_1^n y_i \right)}
\end{align}
$$

which implies $\theta \mid y \sim \dgamma(\alpha + n, \beta + \sum_1^n y_i)$.

Suppose now that we wish to do inference on $\phi := \theta^{-1}$. We will show that $\phi$ has an inverse gamma distribution if $\theta$ has a gamma distribution. Indeed, 

$$
\begin{align}
  p(\phi)
  &\propto
  p(\theta) \left\vert {\frac{d\phi}{d\theta}} \right\vert^{-1}
  \\
  &=
  \theta^{\alpha - 1} e^{-\beta \theta} \cdot\theta^2
  \\
  &=
  \phi^{-\alpha - 1} e^{-\frac{\beta}{\phi}}
  ,
\end{align}
$$

which corresponds to an $\dinvgamma(\alpha, \beta)$ distribution.


Suppose that the lifetime of a light bulb can be modelled as an exponential distribution with rate $\theta$. Let's compare inferences using the two different parameterisations above. For $\theta \sim \dgamma(\alpha, \beta)$, the prior variance is $\frac{\alpha}{\beta^2}$ and the mean is $\frac{\alpha}{\beta}$, so the prior coefficient of variation is $\alpha^{-\frac{1}{2}}$. We are given that the prior coefficient of variation is 0.5, so $\alpha = 4$. The posterior coefficient of variation is $(4 + n)^{-\frac{1}{2}}$. If we wish this to be at most 0.1, then we would need to test at least $n = 96$ light bulbs.

For $\phi \sim \dinvgamma(\alpha, \beta)$, the prior variance is 

$$
\frac{\beta^2}{(\alpha - 1)^2 (\alpha - 2)}
$$ 

and the mean is $\frac{\beta}{\alpha - 1}$, so the prior coefficient of variation is $(\alpha - 2)^{-\frac{1}{2}}$. With a prior coefficient of variation is 0.5, we have $\alpha = 6$. The posterior coefficient of variation is $(6 + n)^{-\frac{1}{2}}$. If we wish this to be at most 0.1, then we would need to test at least $n = 94$ light bulbs.
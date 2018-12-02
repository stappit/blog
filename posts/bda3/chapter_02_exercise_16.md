---
title: "BDA3 Chapter 2 Exercise 16"
author: "Brian Callander"
date: '2018-09-06'
tags: bda chapter 2, solutions, bayes, beta-binomial, marginal
tldr: Here's my solution to exercise 16, chapter 2, of Gelman's Bayesian Data Analysis (BDA), 3rd edition.
---

Here's my solution to exercise 16, chapter 2, of [Gelman's](https://andrewgelman.com/) *Bayesian Data Analysis* (BDA), 3rd edition. There are [solutions](http://www.stat.columbia.edu/~gelman/book/solutions.pdf) to some of the exercises on the [book's webpage](http://www.stat.columbia.edu/~gelman/book/).

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


Suppose $y \mid \theta \sim \dbinomial(n, \theta)$ and $\theta \sim \dbeta(\alpha, \beta)$. Then

$$
\begin{align}
  p(y)
  &=
  \int_0^1 p(y \mid \theta) p(\theta) d\theta
  \\
  &=
  \int_0^1 \binom{n}{y} \theta^y (1 - \theta)^{n - y} \theta^{\alpha - 1} (1 - \theta)^{\beta - 1} d\theta
  \\
  &=
  \binom{n}{y} \frac{\Gamma (y + \alpha) \Gamma (n - y + \beta)}{\Gamma (n + \alpha + \beta)}
.
\end{align}
$$

If this density is constant in $y$ for any $n$, then 

$$
\binom{n}{y} \Gamma (y + \alpha) \Gamma (n - y + \beta) 
$$

is also constant in $y$ for any $n$. In particular, for $n = 1$, we can evaulate this at $y = 0$ and $y = n$ to give

$$
\Gamma (\alpha) \Gamma (1 + \beta) 
=
\Gamma (\beta) \Gamma (1 + \alpha) 
.
$$

[Since](https://en.wikipedia.org/wiki/Gamma_function) $\Gamma (1 + \alpha) = \alpha \Gamma(\alpha)$, it follows that

$$
\beta \Gamma (\alpha) \Gamma (\beta)
=
\alpha \Gamma (\alpha) \Gamma (\beta)
.
$$

Using the fact that the gamma function is always positive on the reals, we can conclude $\alpha = \beta$.

Now, for $n = 2$, we can evaluate at $y = 0$ and $y = 1$ to get

$$
\begin{align}
\Gamma(\alpha) \Gamma(\alpha + 2)
&=
2 \Gamma(\alpha + 1)^2
\\
\Leftrightarrow
(\alpha + 1) \alpha \Gamma (\alpha)^2
&=
2 \alpha^2 \Gamma (\alpha)^2
\\
\Leftrightarrow
\alpha + 1 
&= 
2\alpha
\\
\Leftrightarrow
\alpha 
&=
1
\end{align}
,
$$

where we have used the facts that $\alpha > 0$, $\Gamma(\alpha + 1) = \alpha \Gamma(\alpha)$, and that the gamma function is positive on the reals. Therefore, $\alpha = \beta = 1$. In other words, if the beta-binomial distribution is uniform, then $\alpha = \beta = 1$.


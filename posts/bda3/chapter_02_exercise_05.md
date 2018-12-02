---
title: "BDA3 Chapter 2 Exercise 5"
author: "Brian Callander"
date: "2018-08-24"
tags: bayes, solutions, bda chapter 2, bda, beta, binomial, beta-binomial, variance
tldr: Here's my solution to exercise 5, chapter 2, of Gelman's Bayesian Data Analysis (BDA), 3rd edition.
always_allow_html: yes
output: 
  md_document:
    variant: markdown
    preserve_yaml: yes
---

Here's my solution to exercise 5, chapter 2, of [Gelman's](https://andrewgelman.com/) *Bayesian Data Analysis* (BDA), 3rd edition. There are [solutions](http://www.stat.columbia.edu/~gelman/book/solutions.pdf) to some of the exercises on the [book's webpage](http://www.stat.columbia.edu/~gelman/book/).

<!--more-->



<div style="display:none">
  $\DeclareMathOperator{\dbinomial}{binomial}
   \DeclareMathOperator{\dbern}{Bernoulli}
   \DeclareMathOperator{\dbeta}{beta}$
</div>

Let's derive the prior predictive distribution of a beta-binomial model with a uniform prior. See [stackexchange](https://math.stackexchange.com/questions/122296/how-to-evaluate-this-integral-relating-to-binomial) and [wikipedia](https://en.wikipedia.org/wiki/Beta_function) for useful results for solving the integral below.

$$
\begin{align}
  p(y = k)
  &=
  \int_0^1 p(y = k \mid \theta) p(\theta) d\theta
  \\
  &=
  \binom{n}{k} \cdot \int_0^1 \theta^k (1 - \theta)^{n - k} d\theta
  \\
  &=
  \binom{n}{k} \cdot \frac{1}{\binom{n}{k} \cdot (n + 1)}
  \\
  &=
  \frac{1}{n + 1}
\end{align}
$$

Now let's show that the posterior mean of $\theta$ lies between the prior mean and observed frequency. The posterior is

$$
\begin{align}
  p(\theta \mid y)
  &\propto
  p(y \mid \theta) \cdot p(\theta)
  \\
  &\propto
  \theta^y (1 - \theta)^{n - y}\cdot \theta^{\alpha - 1} (1 - \theta)^{\beta - 1}
  \\
  &=
  \theta^{y + \alpha - 1} (1 - \theta)^{n + \beta - y - 1}.
\end{align}
$$

So $p(\theta \mid y) \sim \dbeta(y + \alpha, n - y + \beta)$, which has mean $\frac{y + \alpha}{n + \alpha + \beta}$. Suppose $\frac{y}{n} \le \frac{\alpha}{\alpha + \beta}$. Then

$$
\begin{align}
  \frac{y}{n}
  &\le
  \frac{y + \alpha}{n + \alpha + \beta}
  \\
  \Leftrightarrow
  y(n + \alpha + \beta)
  &\le
  n(y + \alpha)
  \\
  \Leftrightarrow
  y(\alpha + \beta)
  &\le
  n\alpha
  \\
  \Leftrightarrow
  \frac{y}{n} 
  &\le 
  \frac{\alpha}{\alpha + \beta}
\end{align}
$$

A similar argument shows that $\frac{y + \alpha}{n + \alpha + \beta} \le \frac{\alpha}{\alpha + \beta}$.

If $\frac{y}{n} \ge \frac{\alpha}{\alpha + \beta}$, then the analogous argument shows that $\frac{\alpha}{\alpha + \beta} \le \frac{y + \alpha}{n + \alpha + \beta} \le \frac{y}{n}. \square$

The prior variance is $\mathbb V (\theta) = \frac{\alpha \beta}{(\alpha + \beta)^2(\alpha + \beta + 1)}$. For a uniform prior this is $\frac{1}{4 \cdot 3} = \frac{1}{12}$. The posterior variance with a uniform prior is $\frac{y + 1}{n + 2} \cdot \frac{n - y + 1}{n + 2} \cdot \frac{1}{n + 3}$. For $p \in [0, 1]$, the function $p \mapsto p(1 - p)$ is maximised when $p = 0.5$. Thus for fixed $n$, the posterior variance is maximised when $y = \frac{n}{2}$. This means that the posterior variance is at most $\frac{1}{4} \cdot \frac{1}{n + 3} \le \frac{1}{4n + 12} \le \frac{1}{12}. \square$

Intuitively, the posterior variance should be larger than the prior variance when the observed data is different from what would be expected from the prior distribution. (This can't happen with a uniform prior because every value is equally likely). Indeed, with prior $\theta \sim \dbeta(1, 9)$ and observed data $y = 9, n = 10$, we have $\mathbb V(\theta) = \frac{9}{1100}$ and $\mathbb V(\theta \mid y) = \frac{1}{2} \cdot \frac{1}{2} \cdot \frac{1}{21} = \frac{1}{84}$.

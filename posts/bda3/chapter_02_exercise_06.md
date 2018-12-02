---
title: "BDA3 Chapter 2 Exercise 6"
author: "Brian Callander"
date: "2018-08-25"
tags: bda chapter 2, bda, solutions, bayes, poisson, gamma, negative binomial
tldr: Here's my solution to exercise 6, chapter 2, of Gelman's Bayesian Data Analysis (BDA), 3rd edition.
always_allow_html: yes
output: 
  md_document:
    variant: markdown
    preserve_yaml: yes
---

Here's my solution to exercise 6, chapter 2, of [Gelman's](https://andrewgelman.com/) *Bayesian Data Analysis* (BDA), 3rd edition. There are [solutions](http://www.stat.columbia.edu/~gelman/book/solutions.pdf) to some of the exercises on the [book's webpage](http://www.stat.columbia.edu/~gelman/book/).

<!--more-->

<div style="display:none">
  $\DeclareMathOperator{\dbinomial}{binomial}
   \DeclareMathOperator{\dbern}{Bernoulli}
   \DeclareMathOperator{\dgamma}{gamma}
   \DeclareMathOperator{\dpois}{Poisson}
   \DeclareMathOperator{\dbeta}{beta}$
</div>

Considering the negative binomial variable $y$ as a gamma-Poisson variable, we derive expressions for the mean and variance.

From equation 1.6, $\mathbb E (y) = \mathbb E (\mathbb E(y \mid \theta))$. Since $y \mid \theta \sim \dpois(10n\theta)$, it follows that $\mathbb E (y \mid \theta) = 10n\theta$. The rate $\theta \sim \dgamma(\alpha, \beta)$ so $\mathbb E(\theta) = \frac{\alpha}{\beta}$.  Thus, $\mathbb E(y) = 10n\mathbb E(\theta) = 10n \frac{\alpha}{\beta}$.

We also have $\mathbb V(\theta) = \frac{\alpha}{\beta^2}$ since $\theta \sim \dgamma(\alpha, \beta)$, and $\mathbb V(y \mid \theta) = 10n\theta$ since $y \mid \theta \sim \dpois(10n\theta)$. Thus, 

$$
\begin{align}
  \mathbb V (y) 
  &= 
  \mathbb E(\mathbb V(y \mid \theta)) + \mathbb V (\mathbb E (y \mid \theta)) 
  \\
  &=
  \mathbb E(10n\theta) + \mathbb V (10n\theta)
  \\
  &=
  10n\frac{\alpha}{\beta} + (10n)^2\frac{\alpha}{\beta^2}
  \qquad \square
\end{align}
$$

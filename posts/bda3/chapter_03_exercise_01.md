---
title: "BDA3 Chapter 3 Exercise 1"
author: "Brian Callander"
date: "2018-09-14"
tags: bda chapter 3, solutions, bayes, multinomial, dirichlet, change of variables, beta
always_allow_html: yes
output: 
  md_document:
    variant: markdown
    preserve_yaml: yes
---

Here's my solution to exercise 1, chapter 3, of [Gelman's](https://andrewgelman.com/) *Bayesian Data Analysis* (BDA), 3rd edition. There are [solutions](http://www.stat.columbia.edu/~gelman/book/solutions.pdf) to some of the exercises on the [book's webpage](http://www.stat.columbia.edu/~gelman/book/).

<!--more-->

<div style="display:none">
  $\DeclareMathOperator{\dbinomial}{Binomial}
   \DeclareMathOperator{\dmultinomial}{Multinomial}
   \DeclareMathOperator{\dbern}{Bernoulli}
   \DeclareMathOperator{\dpois}{Poisson}
   \DeclareMathOperator{\dnorm}{Normal}
   \DeclareMathOperator{\dcauchy}{Cauchy}
   \DeclareMathOperator{\dexponential}{Exp}
   \DeclareMathOperator{\ddirichlet}{Dirichlet}
   \DeclareMathOperator{\dgamma}{Gamma}
   \DeclareMathOperator{\dinvgamma}{InvGamma}
   \DeclareMathOperator{\invlogit}{InvLogit}
   \DeclareMathOperator{\logit}{Logit}
   \DeclareMathOperator{\dbeta}{Beta}$
</div>

Let $y \mid \theta \sim \dmultinomial_J(\theta)$ with prior $\theta \sim \ddirichlet_J(\alpha)$. We would like to find the marginal distribution of $\phi := \frac{\theta_1}{\theta_1 + \theta_2}$.

## Marginal posterior of Dirichlet-multinomial

As shown in the book, the posterior is $\theta \mid y \sim \ddirichlet(y + \alpha)$. The marginal posterior of $(\theta_1, \theta_2) \mid y$ can be written as

$$
\begin{align}
  p(\theta_1, \theta_2 \mid y)
  &=
  \int_0^1 p(\theta \mid y) d\theta_3 \dotsm d\theta_{J - 1}
  \\
  &\propto
  \theta_1^{y_1 + \alpha_1 - 1}\theta_2^{y_2 + \alpha_2 - 1}
  \int_0^1 \theta_3^{y_3 + \alpha_3 - 1} \dotsm \theta_{J - 1}^{y_{J - 1} + \alpha_{J - 1} - 1} 
  \left(1 - \sum_1^{J - 1} \theta_j \right)^{y_J + \alpha_J - 1} d\theta_3 \dotsm d\theta_{J - 1}
  .
\end{align}
$$

The tricky part is calculating the integral part, which we define

$$
I 
:=
\int_0^1 \theta_3^{y_3 + \alpha_3 - 1} \dotsm \theta_{J - 1}^{y_{J - 1} + \alpha_{J - 1} - 1} 
\left(1 - \sum_1^{J - 1} \theta_j \right)^{y_J + \alpha_J - 1} d\theta_3 \dotsm d\theta_{J - 1}
.
$$

To calculate $I$, first note that 

$$
\begin{align}
  \int_0^1 \theta^s \left( c - \theta \right)^t d\theta 
  &=
  \int_0^1 \theta^s \left( 1 - \frac{\theta}{c} \right)^t c^t d\theta 
  \\
  &=
  \int_0^1 \left( \frac{\theta}{c} \right)^s \left( 1 - \frac{\theta}{c} \right)^t c^{s + t} d\theta 
  \\
  &=
  \int_0^1 \phi^s \left( 1 - \phi \right)^t c^{s + t + 1} d\phi
  ,
  \quad 
  \phi := \frac{\theta}{c}
  \\
  &=
  B(s + 1, t + 1) c^{s + t + 1} 
  ,
\end{align}
$$

if $c$ is not a function of $\theta$. With $c := 1 - \sum_1^{J - 2} \theta_j$, 

$$
\begin{align}
  I
  &=
  \int_0^1 
  \theta_3^{y_3 + \alpha_3 - 1} \dotsm \theta_{J - 2}^{y_{J - 2} + \alpha_{J - 2} - 1} 
  \theta_{J - 1}^{y_{J - 1} + \alpha_{J - 1} - 1} 
  \left(
    1 - \sum_1^{J - 2} \theta_j - \theta_{J - 1} 
  \right)^{y_J + \alpha_J - 1} 
  d\theta_3 \dotsm d\theta_{J - 1}
  \\
  &=
  \int_0^1 
  \theta_3^{y_3 + \alpha_3 - 1} \dotsm \theta_{J - 2}^{y_{J - 2} + \alpha_{J - 2} - 1}
  \left(
  \int_0^1 
    \theta_{J - 1}^{y_{J - 1} + \alpha_{J - 1} - 1} 
    \left(c - \theta_{J - 1} \right)^{y_J + \alpha_J - 1} 
  d\theta_{J - 1} \right) d\theta_3 \dotsm d\theta_{J - 2}
  \\
  &\propto
  \int_0^1 
  \theta_3^{y_3 + \alpha_3 - 1} \dotsm \theta_{J - 2}^{y_{J - 2} + \alpha_{J - 2} - 1}
  \left( c \right)^{y_{J-1} + y_J + \alpha_{J-1} + \alpha_J - 1}
  d\theta_3 \dotsm d\theta_{J - 2}
  \\
  &=
  \int_0^1 
  \theta_3^{y_3 + \alpha_3 - 1} \dotsm \theta_{J - 2}^{y_{J - 2} + \alpha_{J - 2} - 1}
  \left( 1 - \sum_1^{J-2} \theta_j \right)^{y_{J-1} + y_J + \alpha_{J-1} + \alpha_J - 1}
  d\theta_3 \dotsm d\theta_{J - 2}
  .
\end{align}
$$

Continuing by induction,

$$
I
=
\left(
  1 - \theta_1 - \theta_2
\right) ^ {\sum_3^J (y_j + \alpha_j) - 1}
.
$$

Now that we have the integral part, the marginal posterior can be written

$$
p(\theta_1, \theta_2 \mid y)
\propto
\theta_1^{y_1 + \alpha_1 - 1}\theta_2^{y_2 + \alpha_2 - 1}
\left(
  1 - \theta_1 - \theta_2
\right) ^ {\sum_3^J (y_j + \alpha_j) - 1}
.
$$

This has the form of a Dirichlet distribution, so the marginal posterior is 

$$
\left( \theta_1, \theta_2, 1 - \theta_1 - \theta_2 \right) \mid y
\sim
\ddirichlet\left(y_1 + \alpha_1, y_2 + \alpha_2, \sum_3^J (y_j + \alpha_j) \right)
.
$$

## Change of variables

Now define $(\phi_1, \phi_2) := (\frac{\theta_1}{\theta_1 + \theta_2}, \theta_1 + \theta_2)$, so that $(\theta_1, \theta_2) = (\phi_1\phi_2, \phi_2 - \phi_1\phi_2)$. The Jacobian of this transformation is

$$
\begin{vmatrix}
  \frac{\partial\theta_1}{\partial\phi_1} & \frac{\partial\theta_1}{\partial\phi_2} \\
  \frac{\partial\theta_2}{\partial\phi_1} & \frac{\partial\theta_2}{\partial\phi_2} 
\end{vmatrix}
=
\begin{vmatrix}
  \phi_2 & \phi_1 \\
  -\phi_2 & 1 - \phi_1
\end{vmatrix}
=
\phi_2
.
$$

Therefore, the probability distribution of the new variables is

$$
\begin{align}
  p(\phi_1, \phi_2 \mid y)
  &=
  (\phi_1\phi_2)^{y_1 + \alpha_1 - 1} (\phi_2 (1 - \phi_1))^{y_2 + \alpha_2 - 1} (1 - \phi_2)^{\sum_3^J (y_j + \alpha_j) - 1} \frac{1}{\phi_2}
  \\
  &=
  \phi_1^{y_1 + \alpha_1 - 1} (1 - \phi_1)^{y_2 + \alpha_2 - 1}
  \phi_2^{y_1 + y_2 + \alpha_1 + \alpha_2 - 3} (1 - \phi_2)^{\sum_3^J (y_j + \alpha_j) - 1}
  \\
  &=
  p(\phi_1 \mid y) p(\phi_2 \mid y)
  ,
\end{align}
$$

where 

$$
\begin{align}
\phi_1 \mid y &\sim \dbeta(y_1 + \alpha_1, y_2 + \alpha_2 )
\\
\phi_2 \mid y &\sim \dbeta\left(y_1 + y_2 + \alpha_1 + \alpha_2 - 2, \sum_3^J (y_j + \alpha_j)\right)
.
\end{align}
$$

The marginal posterior for $\phi_1$ is equivalent to the posterior obtained from a $\phi_1 \sim \dbeta(\alpha_1, \alpha_2)$ prior with a $y_1 \mid \phi_1 \sim \dbinomial(y_1 + y_2, \phi_1)$ likelihood.


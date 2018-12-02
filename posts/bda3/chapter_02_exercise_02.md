---
title: "BDA3 Chapter 2 Exercise 2"
author: "Brian Callander"
date: "2018-08-21"
tags: stan, binomial, bayes, solutions, bda chapter 2, bda
tldr: Here's my solution to exercise 2, chapter 2, of Gelman's Bayesian Data Analysis (BDA), 3rd edition.
always_allow_html: yes
output: 
  md_document:
    variant: markdown
    preserve_yaml: yes
---

Here's my solution to exercise 2, chapter 2, of [Gelman's](https://andrewgelman.com/) *Bayesian Data Analysis* (BDA), 3rd edition. There are [solutions](http://www.stat.columbia.edu/~gelman/book/solutions.pdf) to some of the exercises on the [book's webpage](http://www.stat.columbia.edu/~gelman/book/).

<!--more-->



<div style="display:none">
  $\DeclareMathOperator{\dbinomial}{binomial}
   \DeclareMathOperator{\dbern}{Bernoulli}
   \DeclareMathOperator{\dbeta}{beta}$
</div>


We are given the following information about the two coins.

$$
\begin{align}
  p(C_1) &= 0.5 & p(H \mid C_1) &= \dbern(H \mid 0.6) 
  \\
  p(C_2) &= 0.5 & p(H \mid C_2) &= \dbern(H \mid 0.4)
\end{align}
$$

The posterior probability of each coin given two tails is:

$$
\begin{align}
  p(C_1 \mid TT )
  &\propto
  p(TT \mid C_1) \cdot p(C_1)
  \\
  &=
  \left(\frac{2}{5}\right)^2 \frac{1}{2}
  \\
  &=
  \frac{2}{25}
\end{align}
$$
$$
\begin{align}
  p(C_2 \mid TT )
  &\propto
  p(TT \mid C_2) \cdot p(C_2)
  \\
  &=
  \left(\frac{3}{5}\right)^2 \frac{1}{2}
  \\
  &=
  \frac{9}{50}
\end{align}
$$

Both of the previous probabilities are normalised by the same constant. Since $p(C_1 \mid TT) + p(C_2 \mid TT) = 1$, the normalising constant is $\frac{2}{25} + \frac{9}{50} = \frac{13}{50}$. Thus

$$
p(C_1 \mid TT) = \frac{4}{13}
\qquad
\text{and}
\qquad
p(C_2 \mid TT) = \frac{9}{13}.
$$

Let $y$ be the number of additional spins until the next head. Conditional on a coin, $y$ is [geometrically](https://en.wikipedia.org/wiki/Geometric_distribution) distributed. So the expected number of spins before the next head is:

$$
\begin{align}
  \mathbb E(y \mid TT)
  &=
  \frac{4}{13}\mathbb E(y \mid C_1)
  +
  \frac{9}{13}\mathbb E(y \mid C_1)
  \\
  &=
  \frac{4}{13}\frac{5}{3}
  +
  \frac{9}{13}\frac{5}{2}
  \\
  &=
  \frac{20}{39}
  +
  \frac{45}{26}
  \\
  &=
  \frac{175}{78},
\end{align}
$$

which is 2.24359.




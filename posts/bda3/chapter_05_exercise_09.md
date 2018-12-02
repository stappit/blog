---
title: "BDA3 Chapter 5 Exercise 9"
author: "Brian Callander"
date: "2018-12-03"
tags: bda chapter 5, solutions, bayes, improper prior, hierarchical model, binomial
tldr: Here's my solution to exercise 9, chapter 5, of Gelman's Bayesian Data Analysis (BDA), 3rd edition.
always_allow_html: yes
output: 
  md_document:
    variant: markdown
    preserve_yaml: yes
---

Here's my solution to exercise 9, chapter 5, of [Gelman's](https://andrewgelman.com/) *Bayesian Data Analysis* (BDA), 3rd edition. There are [solutions](http://www.stat.columbia.edu/~gelman/book/solutions.pdf) to some of the exercises on the [book's webpage](http://www.stat.columbia.edu/~gelman/book/).

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


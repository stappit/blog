---
always_allow_html: True
author: Brian Callander
date: '2018-10-21'
output:
  md_document:
    preserve_yaml: True
    variant: markdown
tags: bda chapter 3, solutions, bayes, conjugate prior, normal, inverse chi2, normal inverse chi2
tldr: Here's my solution to exercise 9, chapter 3, of Gelman's Bayesian Data Analysis (BDA), 3rd edition.
title: BDA3 Chapter 3 Exercise 9
---

Here's my solution to exercise 9, chapter 3, of
[Gelman's](https://andrewgelman.com/) *Bayesian Data Analysis* (BDA),
3rd edition. There are
[solutions](http://www.stat.columbia.edu/~gelman/book/solutions.pdf) to
some of the exercises on the [book's
webpage](http://www.stat.columbia.edu/~gelman/book/).

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
  \DeclareMathOperator{\dinvchi}{InvChi2}
  \DeclareMathOperator{\dnorminvchi}{NormInvChi2}
  \DeclareMathOperator{\logit}{Logit}
  \DeclareMathOperator{\ddirichlet}{Dirichlet}
  \DeclareMathOperator{\dbeta}{Beta}$

</div>

Suppose we have a normal likelihood
$y \mid \mu, \sigma \sim \dnorm(\mu, \sigma)$ with conjugate priors

$$
\begin{align}
  \sigma^2 &\sim \dinvchi(\nu_0, \sigma_0^2)
  \\
  \mu \mid \sigma^2 &\sim \dnorm\left(\mu_0, \frac{\sigma^2}{\kappa_0}\right)
  .
\end{align}
$$

We need to show that the posterior is

$$
\mu, \sigma^2 \mid y \sim \dnorminvchi\left(\mu_n, \frac{\sigma_n^2}{\kappa_n}, \nu_n, \sigma_n^2\right)
$$

where

$$
\begin{align}
  \mu_n &= \frac{\kappa_0}{\kappa_0 + n}\mu_0 + \frac{n}{\kappa_0 + n} \bar y
  \\
  \kappa_n &= \kappa_0 + n
  \\
  \nu_n &= \nu_0 + n
  \\
  \nu_n \sigma_n^2 &= \nu_0 \sigma_0^2 + (n - 1) s^2 + \frac{\kappa_0 n}{\kappa_0 + n}(\bar y - \mu_0)^2
  .
\end{align}
$$

Using the calculations on pages 67/68, we can compare the factors in
front of the exponentials and the exponents of the exponentials, to see
that it is sufficient to show that

$$
\begin{align}
  \frac{1}{\sigma(\sigma^2)^{-(\nu_n / 2 - 1)}}
  &=
  \frac{1}{\sigma (\sigma^2)^{-(\nu_0 / 2 + 1)} (\sigma^2)^{-n / 2}}
  \\
  \nu_n \sigma_n^2 + \kappa_n (\mu_n - \mu)^2
  &=
  \nu_0 \sigma_0^2 + \kappa_0 (\mu - \mu_0)^2 + (n - 1)s^2 + n(\bar y - \mu)^2
.
\end{align}
$$

The first identity is straight forward so we focus on the second. We
will expand the left hand side and drop any terms we find that match
those on the right. Expanding the LHS in terms on the hyperpriors, we
get

$$
\nu_0 \sigma_0^2 + (n - 1) s^2 + \frac{\kappa_0 n}{\kappa_0 + n}(\bar y - \mu_0)^2
+
(\kappa_0 + n) \left(\frac{\kappa_0}{\kappa_0 + n}\mu_0 + \frac{n}{\kappa_0 + n} \bar y- \mu\right)^2
-
\text{RHS}
\\
=
\frac{\kappa_0 n}{\kappa_0 + n}(\bar y - \mu_0)^2
+
(\kappa_0 + n) \left(\frac{\kappa_0}{\kappa_0 + n}\mu_0 + \frac{n}{\kappa_0 + n} \bar y- \mu\right)^2
-
\kappa_0 (\mu - \mu_0)^2 - n(\bar y - \mu)^2
.
$$

Moving the $\kappa_0 + n$ denominator of the second term out of the
brackets we obtain

$$
\frac{\kappa_0 n}{\kappa_0 + n}(\bar y - \mu_0)^2
+
\frac{1}{(\kappa_0 + n)} \left(\kappa_0\mu_0 + n \bar y- (\kappa_0 + n)\mu\right)^2
-
\kappa_0 (\mu - \mu_0)^2 - n(\bar y - \mu)^2
.
$$

Simplifying and multiplying out the brackets of the second term gives

$$
\begin{align}
  \left(\kappa_0\mu_0 + n \bar y- (\kappa_0 + n)\mu\right)^2
  &=
  \left( \kappa_0 (\mu_0 - \bar y) + (\kappa_0 + n)(\bar y - \mu) \right)^2
  \\
  &=
  \kappa_0^2 (\bar y - \mu_0)^2 + (\kappa_0 + n)^2 (\bar y - \mu)^2 + 2\kappa_0(\kappa_0 + n)(\bar y - \mu)(\mu_0 - \bar y)
. 
\end{align}
$$

Substituting this back in, we can combine the first terms of each and
multiply out all the brackets to get

\begin{align}
  \frac{\kappa_0 n}{\kappa_0 + n}(\bar y - \mu_0)^2
  +
  \frac{1}{\kappa_0 + n} 
  \left( 
    \kappa_0^2 (\bar y - \mu_0)^2 
    + 
    (\kappa_0 + n)^2 (\bar y - \mu)^2 
    + 
    2\kappa_0 (\kappa_0 + n) (\bar y - \mu) (\mu_0 - \bar y) 
  \right)
  \\
  -
  \kappa_0 (\mu - \mu_0)^2 
  - 
  n(\bar y - \mu)^2
  
  \\
  =
  
  \kappa_0 (\bar y - \mu_0)^2 
  + 
  (\kappa_0 + n) (\bar y - \mu)^2 
  + 
  2\kappa_0 (\bar y - \mu) (\mu_0 - \bar y) 
  \\
  -
  \kappa_0 (\mu - \mu_0)^2 
  - 
  n(\bar y - \mu)^2
  
  \\
  =
  
  \color{red}{ \kappa_0 \bar y^2  }
  + 
  \color{blue}{\kappa_0 \mu_0^2}
  - 
  \color{green}{2\kappa_0 \mu_0 \bar y}
  +
  \color{red}{\kappa_0 \bar y^2}
  +
  \color{orange}{\kappa_0 \mu^2}
  -
  \color{black}{2 \kappa_0 \mu \bar y}
  +
  \color{green}{2 \kappa_0 \mu_0 \bar y}
  \\
  +
  \color{black}{2 \kappa_0 \mu \bar y}
  -
  \color{purple}{2 \kappa_0 \mu_0 \mu}
  -
  \color{red}{2 \kappa_0 \bar y^2}
  -
  \color{orange}{\kappa_0 \mu^2}
  -
  \color{blue}{\kappa_0 \mu_0^2}
  +
  \color{purple}{2 \kappa_0 \mu_0 \mu}
  ,
\end{align}

which cancel to 0.

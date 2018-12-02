---
title: "BDA3 Chapter 2 Exercise 3"
author: "Brian Callander"
date: "2018-08-22"
tags: binomial, bayes, solutions, bda chapter 2, bda, normal approximation
tldr: Here's my solution to exercise 3, chapter 2, of Gelman's Bayesian Data Analysis (BDA), 3rd edition.
always_allow_html: yes
output: 
  md_document:
    variant: markdown
    preserve_yaml: yes
---

Here's my solution to exercise 3, chapter 2, of [Gelman's](https://andrewgelman.com/) *Bayesian Data Analysis* (BDA), 3rd edition. There are [solutions](http://www.stat.columbia.edu/~gelman/book/solutions.pdf) to some of the exercises on the [book's webpage](http://www.stat.columbia.edu/~gelman/book/).

<!--more-->



<div style="display:none">
  $\DeclareMathOperator{\dbinomial}{binomial}
   \DeclareMathOperator{\dbern}{Bernoulli}
   \DeclareMathOperator{\dbeta}{beta}$
</div>


For 1000 rolls of a fair die, The mean number of sixs is 1000/6 = 166.667, the variance is 138.889, and the standard deviation is 11.7851. Let's compare the binomial distribution to the normal approximation.


```r
N <- 1000
p <- 1 / 6
mu <- N * p
sigma <- sqrt(N * p * (1 - p))

ex3 <- tibble(
    y = seq(0, N),
    binomial = dbinom(y, N, p),
    normal_approx = dnorm(y, mu, sigma)
  ) %>% 
  gather(metric, probability, -y) 
```

<table class="table" style="margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:right;"> y </th>
   <th style="text-align:left;"> metric </th>
   <th style="text-align:right;"> probability </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:left;"> binomial </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:left;"> binomial </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:left;"> binomial </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:left;"> binomial </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:left;"> binomial </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:left;"> binomial </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
</tbody>
</table>

![plot of chunk ex3_plot](figure/ex3_plot-1.png)

The two curves are visually indistinguishable. The percentiles are listed in the table below.


```r
percentiles <- c(0.05, 0.25, 0.5, 0.75, 0.95)

tibble(
    percentile = scales::percent(percentiles),
    binom = qbinom(percentiles, N, p),
    norm = qnorm(percentiles, mu, sigma)
) %>% kable() %>% kable_styling()
```

<table class="table" style="margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;"> percentile </th>
   <th style="text-align:right;"> binom </th>
   <th style="text-align:right;"> norm </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> 5% </td>
   <td style="text-align:right;"> 147 </td>
   <td style="text-align:right;"> 147.2819 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 25% </td>
   <td style="text-align:right;"> 159 </td>
   <td style="text-align:right;"> 158.7177 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 50% </td>
   <td style="text-align:right;"> 167 </td>
   <td style="text-align:right;"> 166.6667 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 75% </td>
   <td style="text-align:right;"> 175 </td>
   <td style="text-align:right;"> 174.6156 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 95% </td>
   <td style="text-align:right;"> 186 </td>
   <td style="text-align:right;"> 186.0515 </td>
  </tr>
</tbody>
</table>



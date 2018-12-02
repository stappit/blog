---
title: "BDA3 Chapter 2 Exercise 4"
author: "Brian Callander"
date: "2018-08-23"
tags: binomial, bayes, solutions, bda chapter 2, bda, normal approximation, multi-modal
tldr: Here's my solution to exercise 4, chapter 2, of Gelman's Bayesian Data Analysis (BDA), 3rd edition.
always_allow_html: yes
output: 
  md_document:
    variant: markdown
    preserve_yaml: yes
---

Here's my solution to exercise 4, chapter 2, of [Gelman's](https://andrewgelman.com/) *Bayesian Data Analysis* (BDA), 3rd edition. There are [solutions](http://www.stat.columbia.edu/~gelman/book/solutions.pdf) to some of the exercises on the [book's webpage](http://www.stat.columbia.edu/~gelman/book/).

<!--more-->




<div style="display:none">
  $\DeclareMathOperator{\dbinomial}{binomial}
   \DeclareMathOperator{\dbern}{Bernoulli}
   \DeclareMathOperator{\dbeta}{beta}$
</div>


Consider 1000 rolls of an unfair die, where the probability of a 6 is either 1/4, 1/6, or 1/12. Let's draw the distribution and the normal approximation.


```r
N <- 1000
p6 <- c(1 / 4, 1 / 6, 1 / 12)

ex4 <- expand.grid(
    y = seq(0, N),
    theta = p6
  ) %>% 
  mutate(
    mu = N * theta,
    sigma = sqrt(N * theta * (10 - theta)),
    binomial = dbinom(y, N, theta),
    normal_approx = dnorm(y, mu, sigma),
    theta = scales::percent(signif(theta))
  ) %>% 
  select(-mu, -sigma) %>% 
  gather(distribution, probability, binomial, normal_approx) %>% 
  spread(theta, probability) %>% 
  mutate(prior_probability = 0.25 * `8.3%` + 0.5 * `16.7%` + 0.25 * `25.0%`)
```

<table class="table" style="margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:right;"> y </th>
   <th style="text-align:left;"> distribution </th>
   <th style="text-align:right;"> 16.7% </th>
   <th style="text-align:right;"> 25.0% </th>
   <th style="text-align:right;"> 8.3% </th>
   <th style="text-align:right;"> prior_probability </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:left;"> binomial </td>
   <td style="text-align:right;"> 0.0e+00 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.00e+00 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:left;"> normal_approx </td>
   <td style="text-align:right;"> 2.1e-06 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0.0002078 </td>
   <td style="text-align:right;"> 5.30e-05 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:left;"> binomial </td>
   <td style="text-align:right;"> 0.0e+00 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.00e+00 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:left;"> normal_approx </td>
   <td style="text-align:right;"> 2.3e-06 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0.0002297 </td>
   <td style="text-align:right;"> 5.86e-05 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:left;"> binomial </td>
   <td style="text-align:right;"> 0.0e+00 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.00e+00 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:left;"> normal_approx </td>
   <td style="text-align:right;"> 2.5e-06 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0.0002536 </td>
   <td style="text-align:right;"> 6.47e-05 </td>
  </tr>
</tbody>
</table>
  
![plot of chunk ex4_plot](figure/ex4_plot-1.png)

The normal approximation underestimates the maxima and overestimates the values between the maxima. From the percentiles in the table below, we see that the normal approximation is best near the median but becomes gradually worse towards towards both extremes.


```r
percentiles <- c(0.05, 0.25, 0.5, 0.75, 0.95)

ex4 %>% 
  group_by(distribution) %>% 
  arrange(y) %>% 
  mutate(
    cdf = cumsum(prior_probability),
    percentile = case_when(
      cdf <= 0.05 ~ '05%',
      cdf <= 0.25 ~ '25%',
      cdf <= 0.50 ~ '50%',
      cdf <= 0.75 ~ '75%',
      cdf <= 0.95 ~ '95%'
    )
  ) %>% 
  filter(cdf <= 0.95) %>% 
  group_by(distribution, percentile) %>% 
  slice(which.max(cdf)) %>% 
  select(distribution, percentile, y) %>% 
  spread(distribution, y) %>% 
  arrange(percentile) %>% 
  kable() %>% kable_styling()
```

<table class="table" style="margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;"> percentile </th>
   <th style="text-align:right;"> binomial </th>
   <th style="text-align:right;"> normal_approx </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> 05% </td>
   <td style="text-align:right;"> 75 </td>
   <td style="text-align:right;"> 58 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 25% </td>
   <td style="text-align:right;"> 119 </td>
   <td style="text-align:right;"> 110 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 50% </td>
   <td style="text-align:right;"> 166 </td>
   <td style="text-align:right;"> 164 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 75% </td>
   <td style="text-align:right;"> 206 </td>
   <td style="text-align:right;"> 214 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 95% </td>
   <td style="text-align:right;"> 260 </td>
   <td style="text-align:right;"> 291 </td>
  </tr>
</tbody>
</table>



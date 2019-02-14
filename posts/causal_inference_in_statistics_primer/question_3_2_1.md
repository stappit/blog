---
always_allow_html: True
author: Brian Callander
date: '2019-02-10'
output:
  md_document:
    preserve_yaml: True
    variant: markdown
tags: 'CISP chapter 3, solutions, ace, risk difference, simpson''s reversal'
title: 'CIS Primer Question 3.2.1'
tldr: |
    Here are my solutions to question 3.2.1 of Causal Inference in
    Statistics a Primer (CISP).
---

Here are my solutions to question 3.2.1 of Causal Inference in
Statistics: a Primer (CISP).

<!--more-->
Here are the parameters we'll use. Note that they are taken from the
Simpson's revesal example of [question 1.5.2](question_1_5_2.html).

``` {.r}
r   <- 0.28   # fraction with syndrome

q0 <- 0.07  # P(X = 1 | Z = 0)
q1 <- 0.85  # P(X = 1 | Z = 1)
             
p00 <- 0.84 # P(Y = 1 | X = 0, Z = 0)
p10 <- 0.88 # P(Y = 1 | X = 1, Z = 0)
p01 <- 0.53 # P(Y = 1 | X = 0, Z = 1)
p11 <- 0.58 # P(Y = 1 | X = 1, Z = 1)
```

Part a
------

We can simulate the intervention by generating values for $X$
independently of $Z$.

``` {.r}
N <- 10000  # number of individuals

set.seed(53201)

part_a <- tibble(z = rbinom(N, 1, r)) %>% 
  mutate(
    x = rbinom(n(), 1, 0.5), # no Z-dependence
    p_y_given_x_z = case_when(
      x == 0 & z == 0 ~ p00,
      x == 0 & z == 1 ~ p01,
      x == 1 & z == 0 ~ p10,
      x == 1 & z == 1 ~ p11
    ),
    y = rbinom(n(), 1, p_y_given_x_z)
  ) %>% 
  group_by(x, y) %>% 
  summarise(n = n()) %>% 
  group_by(x) %>% 
  mutate(p_y_given_do_x = n / sum(n))
```

<table class="table table-hover table-striped table-responsive" style="margin-left: auto; margin-right: auto;">
<thead>
<tr>
<th style="text-align:right;">
x
</th>
<th style="text-align:right;">
y
</th>
<th style="text-align:right;">
n
</th>
<th style="text-align:right;">
p\_y\_given\_do\_x
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
1238
</td>
<td style="text-align:right;">
0.2470565
</td>
</tr>
<tr>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
3773
</td>
<td style="text-align:right;">
0.7529435
</td>
</tr>
<tr>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
964
</td>
<td style="text-align:right;">
0.1932251
</td>
</tr>
<tr>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
4025
</td>
<td style="text-align:right;">
0.8067749
</td>
</tr>
</tbody>
</table>
Part b
------

To simulate observational data, we need to include the dependence of $X$
on $Z$.

``` {.r}
N <- 100000  # number of individuals

set.seed(95400)

p_x_y_z <- tibble(
    id = 1:N,
    
    z = rbinom(N, 1, r),
    x = rbinom(N, 1, if_else(z == 0, q0, q1)),
    
    p_y_given_x_z = case_when(
      x == 0 & z == 0 ~ p00,
      x == 0 & z == 1 ~ p01,
      x == 1 & z == 0 ~ p10,
      x == 1 & z == 1 ~ p11
    ),
    
    y = rbinom(N, 1, p_y_given_x_z)
  ) %>% 
  group_by(x, y, z) %>% 
  count() %>% 
  ungroup() %>% 
  mutate(p = n / sum(n))
```

<table class="table table-hover table-striped table-responsive" style="margin-left: auto; margin-right: auto;">
<thead>
<tr>
<th style="text-align:right;">
x
</th>
<th style="text-align:right;">
y
</th>
<th style="text-align:right;">
z
</th>
<th style="text-align:right;">
n
</th>
<th style="text-align:right;">
p
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
10723
</td>
<td style="text-align:right;">
0.10723
</td>
</tr>
<tr>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
2020
</td>
<td style="text-align:right;">
0.02020
</td>
</tr>
<tr>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
56015
</td>
<td style="text-align:right;">
0.56015
</td>
</tr>
<tr>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
2205
</td>
<td style="text-align:right;">
0.02205
</td>
</tr>
<tr>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
624
</td>
<td style="text-align:right;">
0.00624
</td>
</tr>
<tr>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
10067
</td>
<td style="text-align:right;">
0.10067
</td>
</tr>
<tr>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
4470
</td>
<td style="text-align:right;">
0.04470
</td>
</tr>
<tr>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
13876
</td>
<td style="text-align:right;">
0.13876
</td>
</tr>
</tbody>
</table>
In order to apply the causal effect rule, we'll need
$\mathbb P(x \mid z)$.

``` {.r}
p_x_given_z <- p_x_y_z %>% 
  group_by(x, z) %>% 
  summarise(n = sum(n)) %>% 
  group_by(z) %>% 
  mutate(p = n / sum(n)) %>% 
  ungroup()
```

<table class="table table-hover table-striped table-responsive" style="margin-left: auto; margin-right: auto;">
<thead>
<tr>
<th style="text-align:right;">
x
</th>
<th style="text-align:right;">
z
</th>
<th style="text-align:right;">
n
</th>
<th style="text-align:right;">
p
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
66738
</td>
<td style="text-align:right;">
0.9290845
</td>
</tr>
<tr>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
4225
</td>
<td style="text-align:right;">
0.1499929
</td>
</tr>
<tr>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
5094
</td>
<td style="text-align:right;">
0.0709155
</td>
</tr>
<tr>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
23943
</td>
<td style="text-align:right;">
0.8500071
</td>
</tr>
</tbody>
</table>
We can then add the conditional probabilities to the joint distribution
table, then sum overal all the $Z$ variables.

``` {.r}
p_y_given_do_x <- p_x_y_z %>% 
  inner_join(
    p_x_given_z, 
    by = c('x', 'z'), 
    suffix = c('_num', '_denom')
  ) %>% 
  mutate(p = p_num / p_denom) %>% 
  group_by(x, y) %>%
  summarise(p = sum(p)) 
```

<table class="table table-hover table-striped table-responsive" style="margin-left: auto; margin-right: auto;">
<thead>
<tr>
<th style="text-align:right;">
x
</th>
<th style="text-align:right;">
y
</th>
<th style="text-align:right;">
p
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0.2500877
</td>
</tr>
<tr>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
0.7499123
</td>
</tr>
<tr>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0.2064264
</td>
</tr>
<tr>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
0.7935736
</td>
</tr>
</tbody>
</table>
The causal effect estimates are very close to the simulated
intervention.

Part c
------

We can calculate ACE simply by taking the difference of the causal
effect estimates.

``` {.r}
ace <- p_y_given_do_x %>% 
  spread(x, p) %>% 
  filter(y == 1) %>% 
  mutate(ace = `1` - `0`) %>% 
  pull(ace)

ace
```

    [1] 0.04366134

This is different from the overall probability differences.

``` {.r}
p_y_given_x <- p_x_y_z %>% 
  group_by(x, y) %>% 
  summarise(n = sum(n)) %>% 
  group_by(x) %>% 
  mutate(p = n / sum(n)) %>% 
  select(-n) 

risk_difference <- p_y_given_x %>% 
  spread(x, p) %>% 
  filter(y == 1) %>% 
  mutate(rd = `1` - `0`) %>% 
  pull(rd)

risk_difference
```

    [1] -0.188613

Making $X$ independent of $Z$ would minimise the disrepancy between ACE
and RD, which would turn the adjustment formula into the formulat for
$\mathbb P(y \mid x$. In other words, setting
$q_0 = q_1 = \mathbb P(X = 1)$ would do the trick.

Part d
------

Note that the desegregated causal effects

-   $p_{1, 0} - p_{0, 0}$ is 0.04; and
-   $p_{1, 1} - p_{0, 1}$ is 0.05,

are both consisent with our calculation for the overall causal effect,
ACE = 4.37%. The generated data are an illustration of Simpson's
reversal because the risk difference, -18.9%, has the opposite sign.

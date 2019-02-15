---
always_allow_html: True
author: Brian Callander
date: '2019-02-15'
output:
  md_document:
    preserve_yaml: True
    variant: markdown
tags: 'CISP chapter 3, solutions, front door criteria, front door adjustment'
title: 'CIS Primer Question 3.4.1'
tldr: |
    Here are my solutions to question 3.4.1 of Causal Inference in
    Statistics a Primer (CISP).
---

Here are my solutions to question 3.4.1 of Causal Inference in
Statistics: a Primer (CISP). $\DeclareMathOperator{\do}{do}$

<!--more-->
If we can only measure one additional variable to estimate the causal
effect of $X$ on $Y$ in figure 3.8, then we should measure $W$. From
[question 3.3.1](question_3_3_1.html) we see that no single variable
satisfies the backdoor criteria. Moreover, visual inspection of the
graph verifies that $W$ satisfies the frontdoor criteria:

1.  it intercepts all (the only) directed paths from $X$ to $Y$;
2.  there is no unblocked path from $X$ to $W$; and
3.  all backdoor paths from $W$ to $Y$ are blocked by $X$.

To illustrate this, lets simulate the causal effect in 3 separate ways:

1.  by intervention,
2.  via the backdoor, and
3.  via the frontdoor.

Here are the data. Note that we have created functions for $W$ and $Y$
for use later.

``` {.r}
N <- 100000

W <- function(x) {
  N <- length(x)
  rbinom(N, 1, inv_logit(-x))
}

Y <- function(d, w, z) {
  N <- length(d)
  rbinom(N, 1, inv_logit(-d - w + 3*z))
}

df <- tibble(id = 1:N) %>% 
  mutate(
    b = rnorm(N, 0, 1),
    a = b + rnorm(N, 0, 0.1),
    c = rnorm(N, 0, 1),
    d = rbinom(N, 1, inv_logit(-1 + c)),
    z = rbinom(N, 1, inv_logit(-2 + 2*b + c)),
    x = rbinom(N, 1, inv_logit(a + z)),
    w = W(x),
    y = Y(d, w, z)
  )
```

<table class="table table-striped table-hover table-responsive" style="margin-left: auto; margin-right: auto;">
<caption>
Simulated data for figure 3.8
</caption>
<thead>
<tr>
<th style="text-align:right;">
id
</th>
<th style="text-align:right;">
b
</th>
<th style="text-align:right;">
a
</th>
<th style="text-align:right;">
c
</th>
<th style="text-align:right;">
d
</th>
<th style="text-align:right;">
z
</th>
<th style="text-align:right;">
x
</th>
<th style="text-align:right;">
w
</th>
<th style="text-align:right;">
y
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
0.3641297
</td>
<td style="text-align:right;">
0.3917626
</td>
<td style="text-align:right;">
1.0369530
</td>
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
0
</td>
<td style="text-align:right;">
1
</td>
</tr>
<tr>
<td style="text-align:right;">
2
</td>
<td style="text-align:right;">
0.0287563
</td>
<td style="text-align:right;">
0.0397299
</td>
<td style="text-align:right;">
0.5736271
</td>
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
1
</td>
<td style="text-align:right;">
0
</td>
</tr>
<tr>
<td style="text-align:right;">
3
</td>
<td style="text-align:right;">
-0.7727052
</td>
<td style="text-align:right;">
-0.5993870
</td>
<td style="text-align:right;">
-0.5179657
</td>
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
1
</td>
<td style="text-align:right;">
1
</td>
</tr>
<tr>
<td style="text-align:right;">
4
</td>
<td style="text-align:right;">
0.4107888
</td>
<td style="text-align:right;">
0.5737898
</td>
<td style="text-align:right;">
1.2586840
</td>
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
0
</td>
<td style="text-align:right;">
1
</td>
</tr>
<tr>
<td style="text-align:right;">
5
</td>
<td style="text-align:right;">
2.3512417
</td>
<td style="text-align:right;">
2.1631719
</td>
<td style="text-align:right;">
0.6746523
</td>
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
0
</td>
<td style="text-align:right;">
1
</td>
</tr>
</tbody>
</table>
Intervention
------------

In order to simulate an intervention, we assign values to $X$ randomly,
then assign new values for all its descendents. After intervention, the
causal effect of $X$ on $Y$ is simply $\mathbb P(Y \mid X)$.

``` {.r}
intervention <- df %>% 
  # intervene on x
  mutate(
    x = rbinom(n(), 1, 0.5),
    w = W(x),
    y = Y(d, w, z)
  ) %>% 
  # model P(y | do(x))
  glm(
    formula = y ~ x, 
    family = binomial(), 
    data = .
  ) %>% 
  # predict
  augment(
    newdata = tibble(x = 0:1), 
    type.predict = 'response'
  ) 
```

<table class="table table-hover table-responsive" style="margin-left: auto; margin-right: auto;">
<caption>
P(Y | do(X))
</caption>
<thead>
<tr>
<th style="text-align:right;">
x
</th>
<th style="text-align:right;">
.fitted
</th>
<th style="text-align:right;">
.se.fit
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0.4637566
</td>
<td style="text-align:right;">
0.0022239
</td>
</tr>
<tr>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
0.5072714
</td>
<td style="text-align:right;">
0.0022422
</td>
</tr>
</tbody>
</table>
We can compare this causal effect to the simple statistical effect to
see the difference.

``` {.r}
noncausal <- df %>% 
  # model P(y | x)
  glm(
    formula = y ~ x, 
    family = binomial(), 
    data = .
  ) %>% 
  # predict
  augment(
    newdata = tibble(x = 0:1), 
    type.predict = 'response'
  ) 
```

<table class="table table-hover table-responsive" style="margin-left: auto; margin-right: auto;">
<caption>
P(Y | X) ≠ P(Y | do(X))
</caption>
<thead>
<tr>
<th style="text-align:right;">
x
</th>
<th style="text-align:right;">
.fitted
</th>
<th style="text-align:right;">
.se.fit
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0.3797282
</td>
<td style="text-align:right;">
0.0022595
</td>
</tr>
<tr>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
0.5759927
</td>
<td style="text-align:right;">
0.0021293
</td>
</tr>
</tbody>
</table>
Backdoor
--------

Since $\{X, Z\}$ satisfies the backdoor criteria, we can use it to apply
the backdoor adjustment. First we'll need $\mathbb P(D, Z)$.

``` {.r}
# P(d, z)
p_d_z <- df %>% 
  group_by(d, z) %>% 
  count() %>% 
  ungroup() %>%  
  mutate(p_d_z = n / sum(n)) 
```

Now we model $\mathbb P(Y \mid X, D, Z)$, multiply it by
$\mathbb P(D, Z)$, then take the sum for each value of $X$.

``` {.r}
backdoor <- formula(y ~ 1 + x + z + d) %>% 
  # model P(y | x, d, z)
  glm(
    family = binomial(),
    data = df
  ) %>%  
  # predict
  augment(
    type.predict = 'response',
    newdata = 
      crossing(
        d = c(0, 1),
        x = c(0, 1),
        z = c(0, 1)
      )
  ) %>% 
  # get P(d, z)
  mutate(p_y_given_d_x_z = .fitted) %>% 
  inner_join(p_d_z, by = c('d', 'z')) %>% 
  # backdoor adjustment over d, z
  group_by(x) %>% 
  summarise(p_y_given_do_x = sum(p_y_given_d_x_z * p_d_z))
```

<table class="table table-striped table-hover table-responsive" style="margin-left: auto; margin-right: auto;">
<caption>
Backdoor estimates for P(Y | do(X))
</caption>
<thead>
<tr>
<th style="text-align:right;">
x
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
0.4681530
</td>
</tr>
<tr>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
0.5033398
</td>
</tr>
</tbody>
</table>
Note that the backdoor adjusted estimates are similar to the estimates
from intervention.

Frontdoor
---------

To apply the frontdoor adjustment with $W$, we'll need
$\mathbb P(W \mid X)$, $\mathbb P(X^\prime)$, and
$\mathbb P(Y \mid X, W)$.

``` {.r}
p_w_given_x <- df %>% 
  group_by(x, w) %>% 
  count() %>% 
  group_by(x) %>% 
  mutate(p_w_given_x = n / sum(n)) %>% 
  ungroup()

p_xprime <- df %>% 
  group_by(xprime = x) %>% 
  count() %>% 
  ungroup() %>% 
  mutate(p_xprime = n / sum(n))

p_y_given_xprime_w <- formula(y ~ 1 + x + w) %>% 
  glm(
    family = binomial(),
    data = df
  ) %>% 
  augment(
    newdata = crossing(x = 0:1, w = 0:1),
    type.predict = 'response'
  ) %>% 
  transmute(
    xprime = x,
    w,
    p_y_given_xprime_w = .fitted
  )
```

Now we apply the frontdoor adjustment:

$$
\mathbb P (Y \mid \do(X))
=
\sum_{x^\prime, w}
\mathbb P(x^\prime)
\cdot
\mathbb P(w \mid x)
\cdot
\mathbb P (y \mid x^\prime, w)
.
$$

``` {.r}
frontdoor <- p_w_given_x %>% 
  inner_join(p_y_given_xprime_w, by = 'w') %>% 
  inner_join(p_xprime, by = 'xprime') %>% 
  group_by(x) %>%
  summarise(sum(p_w_given_x * p_y_given_xprime_w * p_xprime))
```

<table class="table table-hover table-responsive" style="margin-left: auto; margin-right: auto;">
<caption>
Frontdoor estimates of P(Y | do(X))
</caption>
<thead>
<tr>
<th style="text-align:right;">
x
</th>
<th style="text-align:right;">
sum(p\_w\_given\_x \* p\_y\_given\_xprime\_w \* p\_xprime)
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0.4623710
</td>
</tr>
<tr>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
0.5041105
</td>
</tr>
</tbody>
</table>
Our frontdoor estimates of $\mathbb P(Y \mid \do(X))$ are very similar
to the intervention and backdoor estimates.

---
always_allow_html: True
author: Brian Callander
date: '2019-02-10'
output:
  md_document:
    preserve_yaml: True
    variant: markdown
tags: 'CISP chapter 1, solutions, simpson''s reversal, product decomposition'
title: 'CIS Primer Question 1.5.2'
tldr: |
    Here are my solutions to question 1.5.2 of Causal Inference in
    Statistics a Primer (CISP).
---

Here are my solutions to question 1.5.2 of Causal Inference in
Statistics: a Primer (CISP).

<!--more-->
I'll use different indexing to make the notation clearer. In particular,
the indices will match the values of the conditioning variables.

Part a
------

The full joint probability is

$$
\mathbb P(x, y, z)
=
\mathbb P (z) \cdot \mathbb P (x \mid z) \cdot \mathbb P (y \mid x, z)
$$

using the decomposition formula. Each factor is given by

$$
\begin{align}
  \mathbb P (z) 
  &=
  z r + (1 - z) (1 - r)
  \\
  \mathbb P (x \mid z) 
  &=
  xq_z + (1 - x)(1 - q_z)
  \\
  \mathbb P (y \mid x, z)
  &=
  yp_{x, z} + (1 - y)(1 - p_{x, z})
\end{align}
$$

where each parameter is assumed to have support on $\{0, 1\}$.

The marginal distributions are given by

$$
\begin{align}
  \mathbb P(x, z)
  &=
  \mathbb P(x \mid z) \cdot \mathbb P (z)
  \\
  \mathbb P(y, z)
  &=
  \mathbb P(0, y, z) + \mathbb P(1, y, z)
  \\
  \mathbb P(x, y)
  &=
  \mathbb P(x, y, 0) + \mathbb P(x, y, 1)
  \\
  &=
  yp_{x, 0} + (1 - y)(1 - p_{x, 0})
  +
  yp_{x, 1} + (1 - y)(1 - p_{x, 1})
  \\
  &=
  y (p_{x, 0} + p_{x, 1})  + (1 - y)(2 - p_{x, 0} - p_{x, 1})
  .
\end{align}
$$

Furthermore,

$$
\begin{align}
  \mathbb P (x) 
  &=
  \sum_z \mathbb P(x \mid z) \mathbb P (z)
  \\
  &=
  \sum_z (xq_z + (1 - x)(1 - q_z))(zr + (1 - z)(1 - r))
\end{align}
$$

so that

$$
\begin{align}
  \mathbb P(X = 0)
  &=
  (1 - q_0)(1 - r) + (1 - q_1)r
  \\
  \mathbb P(X = 1)
  &=
  q_0(1 - r) + q_1r
\end{align}
$$

Part b
------

The increase in probability from taking the drug in each sub-population
is:

-   $\mathbb P(y = 1 \mid x = 1, z = 0) - \mathbb P(y = 1 \mid x = 0, z = 0) = p_{1, 0} - p_{0, 0}$;
    and
-   $\mathbb P(y = 1 \mid x = 1, z = 1) - \mathbb P(y = 1 \mid x = 0, z = 1) = p_{1, 1} - p_{0, 1}$.

In the whole population, the increase is
$\mathbb P(Y = 1 \mid X = 1) - \mathbb P(Y = 1 \mid X = 0)$, calcualted
via

$$
\begin{align}
  &
  \sum_{z = 0}^1 
  \mathbb P(Y = 1, Z = z \mid X = 1) - \mathbb P(Y = 1, Z = z \mid X = 0)
  \\
  &=
  \sum_{z = 0}^1 
  \frac{\mathbb P(X = 1, Y = 1, Z = z)}{\mathbb P(X = 1)} - \frac{\mathbb P(X = 0, Y = 1, Z = z)}{\mathbb P(X = 0)}
  \\
  &=
  \frac{(1 - r)q_0p_{1, 0} + rq_1p_{1, 1}}{q_0(1 - r) + q_1r} 
  - 
  \frac{(1 - r)(1 - q_0)p_{0, 0} + r(1 - q_1)p_{0, 1}}{(1 - q_0)(1 - r) + (1 - q_1)r}
\end{align}
$$

Part c
------

There's no need to be smart about this. Let's just simulate lots of
values and find some combination with a Simpson's reversal. We'll
generate a dataset with a positive probability difference in each
sub-population, then filter out anything that also has a non-negative
population difference.

``` {.r}
set.seed(8168)

N <- 10000

part_c <- tibble(
  id = 1:N %>% as.integer(),
  
  r = rbeta(N, 2, 2),   # P(Z = 1)
  
  q0 = rbeta(N, 2, 2),  # P(X = 1 | Z = 0)
  q1 = rbeta(N, 2, 2),  # P(X = 1 | Z = 1)
  
  p00 = rbeta(N, 2, 2), # P(Y = 1 | X = 0, Z = 0)
  p10 = rbeta(N, 2, 2) * (p00 - 1) + 1, # P(Y = 1 | X = 1, Z = 0)
  p01 = rbeta(N, 2, 2), # P(Y = 1 | X = 0, Z = 1)
  p11 = rbeta(N, 2, 2) * (p01 - 1) + 1, # P(Y = 1 | X = 1, Z = 1)
  
  diff_pop = (p10 * q0 * (1 - r) + p11 * q1 * r) / (q0 * (1 - r) + q1 * r) - (p00 * (1 - q0) * (1 - r) + p01 * (1 - q1) * r) / ((1 - q0) * (1 - r) + (1 - q1) * r),
  diff_z0 = p10 - p00,
  diff_z1 = p11 - p01
) 
```

As a check, there should be no rows with a non-positive difference.

``` {.r}
check <- part_c %>% 
  filter(diff_z0 <= 0 | diff_z1 <= 0) %>% 
  nrow()

# throw error if there are rows
stopifnot(check == 0)

check
```

    [1] 0

Now we simply throw away any rows with a non-negative population
difference. Here is one combination of parameters exhibiting Simpson's
reversal.

``` {.r}
simpsons_reversal <- part_c %>% 
  filter(diff_pop < -0.05) %>% 
  head(1) %>% 
  gather(term, value)
```

<table class="table table-hover table-striped table-responsive" style="margin-left: auto; margin-right: auto;">
<caption>
Parameters leading to Simpson's reversal
</caption>
<thead>
<tr>
<th style="text-align:left;">
term
</th>
<th style="text-align:right;">
value
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
id
</td>
<td style="text-align:right;">
109.0000000
</td>
</tr>
<tr>
<td style="text-align:left;">
r
</td>
<td style="text-align:right;">
0.2837123
</td>
</tr>
<tr>
<td style="text-align:left;">
q0
</td>
<td style="text-align:right;">
0.0664811
</td>
</tr>
<tr>
<td style="text-align:left;">
q1
</td>
<td style="text-align:right;">
0.8468126
</td>
</tr>
<tr>
<td style="text-align:left;">
p00
</td>
<td style="text-align:right;">
0.8441892
</td>
</tr>
<tr>
<td style="text-align:left;">
p10
</td>
<td style="text-align:right;">
0.8827558
</td>
</tr>
<tr>
<td style="text-align:left;">
p01
</td>
<td style="text-align:right;">
0.5273831
</td>
</tr>
<tr>
<td style="text-align:left;">
p11
</td>
<td style="text-align:right;">
0.5816885
</td>
</tr>
<tr>
<td style="text-align:left;">
diff\_pop
</td>
<td style="text-align:right;">
-0.1933634
</td>
</tr>
<tr>
<td style="text-align:left;">
diff\_z0
</td>
<td style="text-align:right;">
0.0385666
</td>
</tr>
<tr>
<td style="text-align:left;">
diff\_z1
</td>
<td style="text-align:right;">
0.0543054
</td>
</tr>
</tbody>
</table>
As a final check, let's generate a dataset for this set of parameters.

``` {.r}
df <- simpsons_reversal %>% 
  spread(term, value) %>% 
  crossing(unit = 1:N) %>% 
  mutate(
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
  select(unit, x, y, z)
```

The empirical joint probability distribution is as follows.

``` {.r}
p_x_y_z <- df %>% 
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
1068
</td>
<td style="text-align:right;">
0.1068
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
197
</td>
<td style="text-align:right;">
0.0197
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
5609
</td>
<td style="text-align:right;">
0.5609
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
224
</td>
<td style="text-align:right;">
0.0224
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
52
</td>
<td style="text-align:right;">
0.0052
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
1016
</td>
<td style="text-align:right;">
0.1016
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
400
</td>
<td style="text-align:right;">
0.0400
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
1434
</td>
<td style="text-align:right;">
0.1434
</td>
</tr>
</tbody>
</table>
The population-level probability difference is given by:

``` {.r}
diff_pop <- p_x_y_z %>% 
  group_by(x) %>% 
  summarise(p = sum(n * y) / sum(n)) %>% 
  spread(x, p) %>%
  mutate(diff = `1` - `0`)
```

<table class="table table-hover table-striped table-responsive" style="margin-left: auto; margin-right: auto;">
<thead>
<tr>
<th style="text-align:right;">
0
</th>
<th style="text-align:right;">
1
</th>
<th style="text-align:right;">
diff
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:right;">
0.8217808
</td>
<td style="text-align:right;">
0.6319779
</td>
<td style="text-align:right;">
-0.1898028
</td>
</tr>
</tbody>
</table>
which is close to the theoretical value.

Similarly, the sub-population differences are

``` {.r}
diff_z <- p_x_y_z %>% 
  group_by(x, z) %>% 
  summarise(p = sum(n * y) / sum(n)) %>% 
  spread(x, p) %>% 
  mutate(diff = `1` - `0`)
```

<table class="table table-hover table-striped table-responsive" style="margin-left: auto; margin-right: auto;">
<thead>
<tr>
<th style="text-align:right;">
z
</th>
<th style="text-align:right;">
0
</th>
<th style="text-align:right;">
1
</th>
<th style="text-align:right;">
diff
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0.8400479
</td>
<td style="text-align:right;">
0.8849558
</td>
<td style="text-align:right;">
0.0449078
</td>
</tr>
<tr>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
0.5320665
</td>
<td style="text-align:right;">
0.5853061
</td>
<td style="text-align:right;">
0.0532396
</td>
</tr>
</tbody>
</table>
which are also close to the theoretical values we calculated. More
importantly, they have a different sign to the population difference,
confiming that we have case of Simpson's reversal.

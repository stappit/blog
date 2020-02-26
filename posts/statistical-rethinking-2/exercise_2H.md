---
always_allow_html: yes
author: Brian Callander
date: '2020-03-20'
output:
  md_document:
    preserve_yaml: yes
    variant: markdown
tags: 'statistical rethinking, solutions, conditional probability'
title: SR2 Chapter 2 Hard
tldr: |
    Here's my solution to the hard exercises in chapter 2 of McElreath's
    Statistical Rethinking, 2nd edition.
---

Here's my solution to the hard exercises in chapter 2 of McElreath's
Statistical Rethinking, 2nd edition.

<!--more-->
::: {style="display:none"}
$\DeclareMathOperator{\dbinomial}{Binomial}  \DeclareMathOperator{\dbernoulli}{Bernoulli}  \DeclareMathOperator{\dpoisson}{Poisson}  \DeclareMathOperator{\dnormal}{Normal}  \DeclareMathOperator{\dt}{t}  \DeclareMathOperator{\dcauchy}{Cauchy}  \DeclareMathOperator{\dexponential}{Exp}  \DeclareMathOperator{\duniform}{Uniform}  \DeclareMathOperator{\dpamma}{pamma}  \DeclareMathOperator{\dinvpamma}{Invpamma}  \DeclareMathOperator{\invlogit}{InvLogit}  \DeclareMathOperator{\logit}{Logit}  \DeclareMathOperator{\ddirichlet}{Dirichlet}  \DeclareMathOperator{\dbeta}{Beta}$
:::

``` {.r}
N <- 100000

dfa <- tibble(
    species = 'A',
    t1 = rbinom(N, 1, 0.1),
    t2 = rbinom(N, 1, 0.1),
    pa = rbinom(N, 1, 0.8)
  )

dfb <- tibble(
    species = 'B',
    t1 = rbinom(N, 1, 0.2),
    t2 = rbinom(N, 1, 0.2),
    pa = rbinom(N, 1, 1 - 0.65)
  )

df <- dfa %>% bind_rows(dfb)

df %>% sample_n(20)
```

    # A tibble: 20 x 4
       species    t1    t2    pa
       <chr>   <int> <int> <int>
     1 A           0     0     1
     2 B           0     1     0
     3 B           1     0     1
     4 A           0     0     0
     5 A           0     0     1
     6 B           0     1     1
     7 B           0     1     1
     8 B           0     0     1
     9 B           0     0     1
    10 A           0     0     1
    11 A           0     1     1
    12 B           0     1     0
    13 B           0     0     1
    14 B           1     0     1
    15 B           0     0     0
    16 B           0     0     1
    17 A           0     0     1
    18 B           1     0     1
    19 A           0     0     1
    20 A           0     1     1

``` {.r}
h1 <- df %>% 
  filter(t1 == 1) %>% 
  summarise(mean(t2 == 1)) %>% 
  pull()

h2 <- df %>% 
  filter(t1 == 1) %>% 
  summarise(mean(species == 'A')) %>% 
  pull()

h3 <- df %>% 
  filter(t1 == 1, t2 == 0) %>% 
  summarise(mean(species == 'A')) %>% 
  pull()

h4a <- df %>% 
  filter(pa == 1) %>% 
  summarise(mean(species == 'A')) %>% 
  pull()

h4b <- df %>% 
  filter(pa == 1, t1 == 1, t2 == 0) %>% 
  summarise(mean(species == 'A')) %>% 
  pull()
```

<table class="table" style="margin-left: auto; margin-right: auto;">
<caption>
Solutions
</caption>
<thead>
<tr>
<th style="text-align:left;">
exercise
</th>
<th style="text-align:right;">
solution
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
h1
</td>
<td style="text-align:right;">
0.1656479
</td>
</tr>
<tr>
<td style="text-align:left;">
h2
</td>
<td style="text-align:right;">
0.3267616
</td>
</tr>
<tr>
<td style="text-align:left;">
h3
</td>
<td style="text-align:right;">
0.3535947
</td>
</tr>
<tr>
<td style="text-align:left;">
h4a
</td>
<td style="text-align:right;">
0.6950541
</td>
</tr>
<tr>
<td style="text-align:left;">
h4b
</td>
<td style="text-align:right;">
0.5509270
</td>
</tr>
</tbody>
</table>

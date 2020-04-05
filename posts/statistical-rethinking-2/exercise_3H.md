---
always_allow_html: yes
author: Brian Callander
date: '2020-04-05'
output:
  md_document:
    preserve_yaml: yes
    variant: markdown
tags: |
    statistical rethinking, solutions, grid approximation, posterior
    predictive check, posterior predictive distribution, map, binomial, hpdi
title: SR2 Chapter 3 Hard
tldr: |
    Here's my solution to the hard exercises in chapter 3 of McElreath's
    Statistical Rethinking, 2nd edition.
---

Here's my solutions to the hard exercises in chapter 3 of McElreath's
Statistical Rethinking, 2nd edition.

<!--more-->
<div>

$\DeclareMathOperator{\dbinomial}{Binomial}  \DeclareMathOperator{\dbernoulli}{Bernoulli}  \DeclareMathOperator{\dpoisson}{Poisson}  \DeclareMathOperator{\dnormal}{Normal}  \DeclareMathOperator{\dt}{t}  \DeclareMathOperator{\dcauchy}{Cauchy}  \DeclareMathOperator{\dexponential}{Exp}  \DeclareMathOperator{\duniform}{Uniform}  \DeclareMathOperator{\dgamma}{Gamma}  \DeclareMathOperator{\dinvpamma}{Invpamma}  \DeclareMathOperator{\invlogit}{InvLogit}  \DeclareMathOperator{\logit}{Logit}  \DeclareMathOperator{\ddirichlet}{Dirichlet}  \DeclareMathOperator{\dbeta}{Beta}$

</div>

Let's first put the data into a tibble for easier manipulation later.

``` {.r}
data(homeworkch3)

df <- tibble(birth1 = birth1, birth2 = birth2) %>% 
  mutate(birth = row_number())
```

<table class="table table-striped table-hover table-responsive" style="margin-left: auto; margin-right: auto;">
<caption>
The first few rows of the data.
</caption>
<thead>
<tr>
<th style="text-align:right;">
birth1
</th>
<th style="text-align:right;">
birth2
</th>
<th style="text-align:right;">
birth
</th>
</tr>
</thead>
<tbody>
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
</tr>
<tr>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
2
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
3
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
4
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
5
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
6
</td>
</tr>
</tbody>
</table>
3H1
---

Let's check we have the correct total cound and the correct number of
boys.

``` {.r}
h1_counts <- df %>% 
  gather(order, gender, -birth) %>% 
  summarise(boys = sum(gender), births = n())
```

Now we can grid approximate the posterior as before.

``` {.r}
granularity <- 1000

h1_grid <- tibble(p = seq(0, 1, length.out = granularity)) %>% 
  mutate(prior = 1)

h1_posterior <- h1_grid %>% 
  mutate(
    likelihood = dbinom(h1_counts$boys, h1_counts$births, p),
    posterior = prior * likelihood,
    posterior = posterior / sum(posterior)
  )
```

The maximum a posteriori (MAP) value is the value of p that maximises
the posterior.

``` {.r}
h1_map <- h1_posterior %>% 
  slice(which.max(posterior)) %>% 
  pull(p)

h1_map
```

    [1] 0.5545546

![Solution 3H1: posterior probability of giving birth to a
boy.](exercise_3H_files/figure-markdown/h1_posterior_plot-1.svg)

3H2
---

We draw samples with weight equalt to the posterior. We then apply the
`HPDI` function to these samples, each time with a different width.

``` {.r}
h2_samples <- h1_posterior %>% 
  sample_n(10000, replace = TRUE, weight = posterior) %>% 
  pull(p)

h2_hpdi <- h2_samples %>% 
  crossing(prob = c(0.5, 0.89, 0.97)) %>% 
  group_by(prob) %>% 
  group_map(HPDI) 

h2_hpdi
```

    [[1]]
         |0.5      0.5| 
    0.4574575 0.5735736 

    [[2]]
        |0.89     0.89| 
    0.4534535 0.6606607 

    [[3]]
        |0.97     0.97| 
    0.4294294 0.6616617 

3H3
---

The posterior predictive samples are possible observations according to
our posterior.

``` {.r}
h3_posterior_predictive <- rbinom(10000, 200, h2_samples)
```

![Solution 3H3: the posterior predictive distribution for 200
births](exercise_3H_files/figure-markdown/h3_plot-1.svg)

The number of observed births is very close to the MAP of the posterior
predictive distribution, suggesting we have a decent fit.

3H4
---

Our data are from birth pairs and so far we didn't make any distinction
between the first and second births. To test this assumption, we can
perform a posterior predictive check as in 3H3, but this time for first
births.

``` {.r}
h4_posterior_predictive <- rbinom(10000, 100, h2_samples)
```

![Solution 3H4: the posterior predictive distribution for 100
births](exercise_3H_files/figure-markdown/h4_posterior_predictive_plot-1.svg)

The fit doesn't look quite as good for first births as it did for all
births together. It also doesn't look bad since there is still a fair
bit of probability mass around the observed number of first birth boys.

3H5
---

As the final posterior predictive check, let's check the number of boys
born after a girl.

``` {.r}
h5_counts <- df %>% 
  filter(birth1 == 0) %>% 
  summarise(boys = sum(birth2), births = n())

h5_posterior_predictive <- rbinom(10000, h5_counts$births, h2_samples)
```

![Solution 3H5: the posterior predictive distribution for 100
births](exercise_3H_files/figure-markdown/h5_posterior_predictive-1.svg)

The fit here looks bad, since the observed number of boys is higher than
the bulk of the model's expectations.

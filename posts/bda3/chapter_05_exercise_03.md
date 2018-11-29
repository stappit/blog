---
always_allow_html: True
author: Brian Callander
date: '2018-11-10'
output:
  md_document:
    preserve_yaml: True
    variant: markdown
tags: |
    bda chapter 5, solutions, bayes, hierarchical model, eight schools,
    pooling
title: BDA3 Chapter 5 Exercise 3
---

Here's my solution to exercise 3, chapter 5, of
[Gelman's](https://andrewgelman.com/) *Bayesian Data Analysis* (BDA),
3rd edition. There are
[solutions](http://www.stat.columbia.edu/~gelman/book/solutions.pdf) to
some of the exercises on the [book's
webpage](http://www.stat.columbia.edu/~gelman/book/).

<!--more-->
<div style="display:none">

$\DeclareMathOperator{\dbinomial}{Binomial}  \DeclareMathOperator{\dbern}{Bernoulli}  \DeclareMathOperator{\dpois}{Poisson}  \DeclareMathOperator{\dnorm}{Normal}  \DeclareMathOperator{\dt}{t}  \DeclareMathOperator{\dcauchy}{Cauchy}  \DeclareMathOperator{\dexponential}{Exp}  \DeclareMathOperator{\duniform}{Uniform}  \DeclareMathOperator{\dgamma}{Gamma}  \DeclareMathOperator{\dinvgamma}{InvGamma}  \DeclareMathOperator{\invlogit}{InvLogit}  \DeclareMathOperator{\logit}{Logit}  \DeclareMathOperator{\ddirichlet}{Dirichlet}  \DeclareMathOperator{\dbeta}{Beta}$

</div>

We'll reproduce some of the calculations with different priors for the
eight schools example. Here is the [eight schools
dataset](data/eight_schools.csv).

``` {.r}
df <- read_csv('data/eight_schools.csv') %>% 
  mutate(school = factor(school))
```

<table class="table table-striped table-hover table-responsive" style="margin-left: auto; margin-right: auto;">
<thead>
<tr>
<th style="text-align:left;">
school
</th>
<th style="text-align:right;">
y
</th>
<th style="text-align:right;">
std
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
A
</td>
<td style="text-align:right;">
25
</td>
<td style="text-align:right;">
15
</td>
</tr>
<tr>
<td style="text-align:left;">
B
</td>
<td style="text-align:right;">
8
</td>
<td style="text-align:right;">
10
</td>
</tr>
<tr>
<td style="text-align:left;">
C
</td>
<td style="text-align:right;">
-3
</td>
<td style="text-align:right;">
16
</td>
</tr>
<tr>
<td style="text-align:left;">
D
</td>
<td style="text-align:right;">
7
</td>
<td style="text-align:right;">
11
</td>
</tr>
<tr>
<td style="text-align:left;">
E
</td>
<td style="text-align:right;">
-1
</td>
<td style="text-align:right;">
19
</td>
</tr>
<tr>
<td style="text-align:left;">
F
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
11
</td>
</tr>
<tr>
<td style="text-align:left;">
G
</td>
<td style="text-align:right;">
18
</td>
<td style="text-align:right;">
10
</td>
</tr>
<tr>
<td style="text-align:left;">
H
</td>
<td style="text-align:right;">
12
</td>
<td style="text-align:right;">
18
</td>
</tr>
</tbody>
</table>
Uniform priors
--------------

We'll use [Stan](http://mc-stan.org/) to calculate the correct posterior
for us. Note that Stan will assume a uniform prior (on the domain of the
parameter) unless otherwise specified.

``` {.r}
model <- rstan::stan_model('src/ex_05_03.stan')
```

    S4 class stanmodel 'ex_05_03' coded as follows:
    data {
      int<lower = 0> J; // number of schools 
      vector[J] y; // estimated treatment effects
      vector<lower = 0>[J] sigma; // standard errors
    }

    parameters {
      real mu; // pop mean
      real<lower = 0> tau; // pop std deviation
      vector[J] eta; // school-level errors
    }

    transformed parameters {
      vector[J] theta = mu + tau * eta; // school effects
    }

    model {
      eta ~ normal(0, 1);
      y ~ normal(theta, sigma);
    } 

We fit the model with the
[sampling](http://mc-stan.org/rstan/reference/stanmodel-method-sampling.html)
function.

``` {.r}
fit <- model %>% 
  rstan::sampling(
    data = list(
      J = nrow(df),
      y = df$y,
      sigma = df$std
    ),
    warmup = 1000,
    iter = 5000,
    chains = 4
  )
```

The [tidybayes
package](https://mjskay.github.io/tidybayes/articles/tidybayes.html) is
super useful for custom calculations from the posterior draws. We'll
also add in the original school labels.

``` {.r}
draws <- fit %>% 
  tidybayes::spread_draws(mu, tau, eta[school_idx]) %>% 
  mutate(
    theta = mu + tau * eta,
    school = levels(df$school)[school_idx]
  ) 
```

We have 4 chains, each with 4000 (post-warmup) iterations, with a draw
for each school parameter. Each draw is one sample from the posterior.

<table class="table table-striped table-hover table-responsive" style="margin-left: auto; margin-right: auto;">
<thead>
<tr>
<th style="text-align:right;">
.chain
</th>
<th style="text-align:right;">
.iteration
</th>
<th style="text-align:right;">
.draw
</th>
<th style="text-align:right;">
mu
</th>
<th style="text-align:right;">
tau
</th>
<th style="text-align:right;">
school\_idx
</th>
<th style="text-align:right;">
eta
</th>
<th style="text-align:right;">
theta
</th>
<th style="text-align:left;">
school
</th>
</tr>
</thead>
<tbody>
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
8.498217
</td>
<td style="text-align:right;">
2.685788
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
1.6796328
</td>
<td style="text-align:right;">
13.009354
</td>
<td style="text-align:left;">
A
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
8.498217
</td>
<td style="text-align:right;">
2.685788
</td>
<td style="text-align:right;">
2
</td>
<td style="text-align:right;">
-0.9133598
</td>
<td style="text-align:right;">
6.045126
</td>
<td style="text-align:left;">
B
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
8.498217
</td>
<td style="text-align:right;">
2.685788
</td>
<td style="text-align:right;">
3
</td>
<td style="text-align:right;">
0.1107519
</td>
<td style="text-align:right;">
8.795673
</td>
<td style="text-align:left;">
C
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
8.498217
</td>
<td style="text-align:right;">
2.685788
</td>
<td style="text-align:right;">
4
</td>
<td style="text-align:right;">
1.4297585
</td>
<td style="text-align:right;">
12.338245
</td>
<td style="text-align:left;">
D
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
8.498217
</td>
<td style="text-align:right;">
2.685788
</td>
<td style="text-align:right;">
5
</td>
<td style="text-align:right;">
1.3404477
</td>
<td style="text-align:right;">
12.098375
</td>
<td style="text-align:left;">
E
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
8.498217
</td>
<td style="text-align:right;">
2.685788
</td>
<td style="text-align:right;">
6
</td>
<td style="text-align:right;">
0.3785970
</td>
<td style="text-align:right;">
9.515048
</td>
<td style="text-align:left;">
F
</td>
</tr>
</tbody>
</table>
Tidybayes also gives us convenient ggplot geoms for plotting the
posterior distributions.

![](chapter_05_exercise_03_files/figure-markdown/effects_plot-1..svg)

``` {.r}
comparisons <- draws %>% 
  group_by(school) %>% 
  tidybayes::compare_levels(theta, by = school) %>% 
  tidybayes::mean_qi()
```

![](chapter_05_exercise_03_files/figure-markdown/comparisons_plot-1..svg)

We can also see how the estimated treatment effect varies as a function
of the population variation. The curves are noiser than in the book
because we are using our posterior draws to approximate the shape and
there are relatively fewer draws for larger values of $\tau$.

![](chapter_05_exercise_03_files/figure-markdown/effect_vs_tau-1..svg)

Here's a simple histogram of the posterior draws for school A.

![](chapter_05_exercise_03_files/figure-markdown/school_a_effect_plot-1..svg)

To estimate the posterior for the maximum effect, we can simply
calculate the maximum effect across all schools for each posterior draw.

``` {.r}
max_theta <- draws %>% 
  group_by(.chain, .iteration, .draw) %>% 
  slice(which.max(theta)) %>% 
  ungroup()
```

The probability that the maximum effect is larger than 28.4 can then be
approximated by the fraction of draws larger than 28.4.

``` {.r}
p_max_theta <- max_theta %>% 
  mutate(larger = theta > 28.4) %>% 
  summarise(p_larger = sum(larger) / n()) %>% 
  pull() %>% 
  percent()

p_max_theta
```

    [1] "6.97%"

![](chapter_05_exercise_03_files/figure-markdown/max_plot-1..svg)

To estimate the probability than the effect in school A is larger than
the effect in school C, we first have to spread the data so that there
is one draw per row.

``` {.r}
a_better_c <- draws %>% 
  ungroup()  %>% 
  select(.chain, .iteration, school, theta) %>% 
  spread(school, theta) %>% 
  mutate(a_minus_c = A - C) 
```

The probability is then just the fraction of draws where A - C &gt; 0.

``` {.r}
prob_a_better_c <- a_better_c %>% 
  summarise(mean(a_minus_c > 0)) %>% 
  pull() %>% 
  percent()

prob_a_better_c
```

    [1] "65%"

![](chapter_05_exercise_03_files/figure-markdown/a_better_c_plot-1..svg)

Infinite population variance
----------------------------

With $\tau = \infty$, we would expect there to be no shrinkage. From
equation 5.17 (page 116), the posteriors of the school effects with
$\tau \to \infty$ are

$$
\begin{align}
  \theta_j \mid \mu, \tau = \infty, y \sim \dnorm\left( \bar y_{\cdot j}, \sigma_j^2 \right)
\end{align}
$$

since $\frac{1}{\tau} \to 0$ as $\tau \to \infty$.

``` {.r}
iters <- 16000

draws_infty <- df %>% 
  transmute(
    school,
    draws = map2(
      y, std, 
      function(mu, sigma) {
        tibble(
          iteration = 1:iters,
          theta = rnorm(iters, mu, sigma)
        )
      }
    )
  ) %>% 
  unnest(draws) %>% 
  arrange(iteration)
```

<table class="table table-striped table-hover table-responsive" style="margin-left: auto; margin-right: auto;">
<thead>
<tr>
<th style="text-align:left;">
school
</th>
<th style="text-align:right;">
iteration
</th>
<th style="text-align:right;">
theta
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
A
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
17.305220
</td>
</tr>
<tr>
<td style="text-align:left;">
B
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
14.584088
</td>
</tr>
<tr>
<td style="text-align:left;">
C
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
-8.254098
</td>
</tr>
<tr>
<td style="text-align:left;">
D
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
-5.412114
</td>
</tr>
<tr>
<td style="text-align:left;">
E
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
-5.607103
</td>
</tr>
<tr>
<td style="text-align:left;">
F
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
6.429439
</td>
</tr>
</tbody>
</table>
We calculate the maximum effect just as before. The histogram shows that
there is a higher probability of higher treatment effects than under the
hierarchical model.

``` {.r}
max_theta_infty <- draws_infty %>% 
  group_by(iteration) %>% 
  slice(which.max(theta))
```

``` {.r}
p_max_theta_infty <- max_theta_infty %>% 
  ungroup() %>% 
  mutate(larger = theta > 28.4) %>% 
  summarise(p_larger = sum(larger) / n()) %>% 
  pull() %>% 
  percent()

p_max_theta_infty
```

    [1] "63.8%"

There is now a 63.8% probability of an extreme effect under the unpooled
model, which is a lot larger than 6.97% under the hierarchical model.

![](chapter_05_exercise_03_files/figure-markdown/max_plot_infty-1..svg)

For the pairwise differences, both the point estimates and the credible
intervals are more extreme.

``` {.r}
comparisons_infty <- draws_infty %>% 
  group_by(school) %>% 
  compare_levels(theta, by = school, draw_indices = c('iteration')) %>% 
  select(-starts_with('iter')) %>% 
  mean_qi()
```

![](chapter_05_exercise_03_files/figure-markdown/comparisons_infty_plot-1..svg)

Zero population variance
------------------------

With $\tau = 0$, we would expect the estimates of school effects to all
be equal to the population effect. Letting $\tau \to 0$ in equation 5.17
(page 116), we see that $\theta_j \mid \mu, \tau, y$ gets a point mass
at \$\mu. This follows from the fact that

$$
\frac{\frac{1}{\tau}}{c + \frac{1}{\tau}} \to 1 \to \infty
$$

for any fixed $c$ as $\tau \to 0$. Thus,

$$
\begin{align}
  \hat \theta_j
  &=
  \frac{\frac{\bar y_{\cdot j}}{\sigma_j}}{\frac{1}{\sigma_j} + \frac{1}{\tau^2}} + \frac{\frac{1}{\tau^2}}{\frac{1}{\sigma_j} + \frac{1}{\tau^2}}\mu
  \to
  0 + \mu
  \\
  V_j &\to 0
  .
\end{align}
$$

It follows that $p(\theta \mid \mu, \tau, y) \to p(\mu \mid \tau, y)$ as
$\tau \to 0$. From equation 5.20 (page 117), the distribution of
$\mu \mid \tau, y$ is $\dnorm(\hat\mu, V_\mu)$ with

$$
\begin{align}
\hat \mu 
&= 
\frac{\sum_1^J \frac{1}{\sigma_j^2} \bar y_{\cdot j}}{\sum_1^J \frac{1}{\sigma_j^2}}
=
\bar y_{\cdot \cdot}
\\
V_\mu^{-1}
&=
\sum_1^J \frac{1}{\sigma_j^2}
.
\end{align}
$$

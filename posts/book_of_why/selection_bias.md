---
always_allow_html: True
author: Brian Callander
date: '2019-01-13'
output:
  md_document:
    preserve_yaml: True
    variant: markdown
tags: |
    judea pearl, causality, selection bias, confounders, experiments,
    surveys, ctr, binomial, stan
title: Selection bias in online experiments
tldr: |
    We simulate data to explore causality as described in Judea Pearl's Book
    of Why. In particular, we look at selection bias in online binomial
    experiments and show that ignoring the causal graph can 1. give wrong
    estimates of the CTR, and 2. mask actual differences in the CTRs. We
    then rectify the above problems using the backdoor adjustment, as
    implied by the causal graph.
---

After reading [Judea Pearl's](http://bayes.cs.ucla.edu/home.htm) [Book
of Why](http://bayes.cs.ucla.edu/WHY/), I wanted to get to grips with
causality in a familiar context: selection bias in online experiments
and surveys. In such experiments, the cohorts are assigned randomly but
we can only collect data on those users who actually log in and navigate
to the section where the experiment has been set up. User engagement a
possible and plausible confounder here, since your more engaged users
are both more likely to log in and more/less enthusiastic about the
particular change introduced in the experiment.

We'll run a simulation in the context of measuring the [click-through
rate (CTR)](https://en.wikipedia.org/wiki/Click-through_rate) of two
cohorts, showing that selection bias can:

1.  give wrong estimates of the CTRs, and
2.  mask actual differences in the CTRs.

We'll then rectify the above problems by defining a causal model and
using the [backdoor
adjustment](http://nickchk.com/causalgraphs.html#control).

Feel free to [download the Rmarkdown](selection_bias.Rmd) and try it out
for yourself.

<!--more-->
<div style="display:none">

$\DeclareMathOperator{\do}{do}$

</div>

The problem
-----------

Let's first show via simulation that it's not possible to estimate the
CTR of each cohort purely from the data. In the following section, we'll
show how to solve this problem by adding causal assumptions.

### The data

We'll assume that our list of users below is the population of interest
and that we have segmented them by their levels of engagement. Both
`engagement` and `segment` in the `users` dataset indicate the same
information, where `engagement` is for convenience in our calculations
and `segment` is for convenience of human-readability.

``` {.r}
set.seed(6490418) # for reproducibility

n_users <- 500000

engagement_segments <- c('low', 'medium', 'high', 'very_high')

users <- tibble(id = 1:n_users) %>% 
  mutate(
    cohort = rbinom(n_users, 1, 0.1),
    engagement = rbinom(n_users, 3, 0.15) - 1,
    segment = engagement_segments[engagement + 2] %>% 
      ordered(levels = engagement_segments)
  )
```

In this situation, most of our users have a low level of engagement.

![Engagement
distribution](selection_bias_files/figure-markdown/engagement_distribution-1..svg)

We then run our experiment and observe whether each user logged in
(`login`), whether they viewed the particular section of the website
where the experiment was taking place (`viewed`), and whether they
clicked the button of interest (`clicked`). Included are also a couple
of unobserved features: `ctr`, indicating the probability of that user
clicking, and `would_have_clicked`, indicating whether the user would
have clicked had they taken part in the experiment.

``` {.r}
xp_complete <- users %>% 
  mutate(
    login = rbinom(n_users, 1, inv_logit(engagement)) > 0,
    viewed = login & rbinom(n_users, 1, 0.5) > 0,
    ctr = inv_logit(-1 + engagement + engagement * cohort),
    would_have_clicked = rbinom(n_users, 1, ctr) > 0,
    clicked = viewed & would_have_clicked
  )
```

The engagement level is an integer between \[-1, 2\] (for convenience),
which we map to a login probability via the [inverse logit
function](https://en.wikipedia.org/wiki/Logit). After logging in, the
user will only take part in the experiment if they navigate to the
correct page. If they do trigger a view in the experiment, the
probability they also click is given as a (non-linear) function of
`engagement` and `cohort`. The specific function used above assumes that
more engaged users are more likely to click in general, and are also
more likely to click if they are in cohort 1.

### Without causal assumptions

We want to know which of the cohorts is more likely to click, regardless
of whether they took part in this particular experiment. Thus, averaging
`would_have_clicked` for each cohort will show us which is better
overall. In this case, the large number of low-engagement users, who
prefer cohort 0, tip the scales towards cohort 0.

``` {.r}
actual <- xp_complete %>% 
  group_by(cohort) %>% 
  summarise(
    views = n(),
    clicks = sum(would_have_clicked),
    ctr = clicks / views
  )  
```

<table class="table table-striped table-hover table-responsive" style="margin-left: auto; margin-right: auto;">
<thead>
<tr>
<th style="text-align:right;">
cohort
</th>
<th style="text-align:right;">
views
</th>
<th style="text-align:right;">
clicks
</th>
<th style="text-align:right;">
ctr
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
449976
</td>
<td style="text-align:right;">
86476
</td>
<td style="text-align:right;">
0.1921791
</td>
</tr>
<tr>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
50024
</td>
<td style="text-align:right;">
8155
</td>
<td style="text-align:right;">
0.1630217
</td>
</tr>
</tbody>
</table>
The problem is that we don't observe `would_have_clicked`. Using only
the observed data leads us to a different conclusion: that there is no
difference in the cohorts.

``` {.r}
observed <- xp_complete %>% 
  filter(viewed) %>%
  group_by(cohort) %>% 
  summarise(
    views = n(),
    clicks = sum(clicked),
    ctr = clicks / views
  )  
```

<table class="table table-striped table-hover table-responsive" style="margin-left: auto; margin-right: auto;">
<thead>
<tr>
<th style="text-align:right;">
cohort
</th>
<th style="text-align:right;">
views
</th>
<th style="text-align:right;">
clicks
</th>
<th style="text-align:right;">
ctr
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
84149
</td>
<td style="text-align:right;">
19500
</td>
<td style="text-align:right;">
0.2317318
</td>
</tr>
<tr>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
9401
</td>
<td style="text-align:right;">
2146
</td>
<td style="text-align:right;">
0.2282736
</td>
</tr>
</tbody>
</table>
Let's quantify our uncertainty in the above statements by fitting some
models.

### A non-causal analysis

In this section we will analyse the observed experimental data without
any causal assumptions. Note that this is the wrong way to analyse this
data. We'll use an informative Bayesian prior centred around the 'true'
population values to emphasise that these problems cannot be solved in
this way. More specifically, we'll assume a prior baseline CTR around
19%, which matches the population CTR for cohort 0, and that the
difference is centred around 0.

``` {.r}
n_sims <- 20000

ctr_baseline <- xp_complete %>% 
  filter(cohort == 0) %>% 
  summarise(ctr = mean(would_have_clicked)) %>% 
  pull(ctr)

priors <- tibble(
  baseline_linear = rnorm(n_sims, logit(ctr_baseline), 0.5),
  baseline = baseline_linear %>% inv_logit(),
  effect = (baseline_linear + rnorm(n_sims, 0, 0.4)) %>% inv_logit()
) 
```

![Prior
distributions](selection_bias_files/figure-markdown/prior_distribution_plot-1..svg)

The prior distribution under the assumption that there is an effect has
thicker tails than the baseline distribution because the former allows
for an increase or decrease in CTR. The priors are informative of the
true values but still have a lot of variance.

Let's fit a binomial model to our data.

``` {.r}
prior_intercept <- normal(logit(ctr_baseline), 0.5)
prior <- normal(0, 0.4)

model_noncausal <- rstanarm::stan_glm(
  # standard binomial test
  cbind(clicks, views - clicks) ~ 1 + cohort,
  family = binomial(),
  data = observed,
  # bayesian priors
  prior_intercept = prior_intercept,
  prior = prior,
  # MCMC sample size
  chains = 4,
  warmup = 1000,
  iter = 5000
)
```

Our Bayesian model allows us to draw a sample of possible CTRs for each
cohort after having updated our prior with the observed data. The CTR
estimates are sereval percentage points higher than the actual CTRs of
interest because the participants consist disproportionately of the more
engaged users, who are more click-happy.

``` {.r}
draws_noncausal <- tibble(cohort = 0:1) %>% 
  tidybayes::add_fitted_draws(model_noncausal) %>% 
  as_tibble() %>% 
  select(.draw, cohort, ctr = .value)
```

![Posterior CTR ignoring causal
model](selection_bias_files/figure-markdown/draws_noncausal_plot-1..svg)

The two distributions above are fairly close together. Using our
Bayesian estimates to calculate the estimated difference in CTRs, we see
that cohort 1 is slightly more likely to have a smaller CTR than cohort
0. However, the histogram is far from reflecting the actual difference
of \~3 percentage points.

``` {.r}
draws_noncausal_diff <- draws_noncausal %>% 
  spread(cohort, ctr) %>% 
  mutate(difference = `1` - `0`) 
```

![Posterior of CTR difference ignoring causal
model](selection_bias_files/figure-markdown/draws_noncausal_diff_plot-1..svg)

The problems outlined above are a direct result of ignoring the causal
assumptions in our experimental setup.

Causal analysis
---------------

We can describe the problems above by drawing the causal diagrams for
our assumptions. The correct causal diagram will then tell us how to get
better estimates.

### Causal diagrams

The causal model used in the previous section consists of only two
nodes: `cohort` and `click`. This correctly assumes that cohort causes
click but incorrectly assumes there are no confounders.

![Wrong causal model](./tikz/wrong.svg){width="60%"}

Although we intervene on `cohort` (there are no arrows into `cohort`),
users can chose whether they take part in the experiments so we should
model this self selection. The case we are interested in posits
`engagement` as a confounder for participation and clicking.

![Simple causal model](./tikz/simple.svg){width="90%"}

This looks like a setup where `cohort` is an instrumental variable for
measuring the causal effect of `view` on `click`. If it were, we
wouldn't have to condition on `engagement`. The reason it is not an
instrumental variable is that our data are collected only for users who
`view`, implying that we are implicitly conditioning on `view`, a
collider. As such, we unblock the non-causal path `cohort` → `view` ←
`engagement` → `click`. To block it, we need to condition on
`engagement`.

### The backdoor adjustment

Given our simple model above, we can use the backdoor criterion to find
the causal effect of `view`. Note that `view` is considered to have 3
possible values: "did not participate", "participated in cohort 0", and
"participated in cohort 1". The causal effect of `view` on `click` is
then

$$
\begin{align}
  \mathbb P (C = 1 \mid \do(V = v)) 
  &= 
  \sum_{e=-1}^2 \mathbb P (C = 1 \mid V = v, E = e) \mathbb P(E = e)
  \\
  &=
  \mathbb P (C = 1 \mid V = v, E = -1) \times 0.614
  \\
  &\mathbin{\hphantom{=}}
  +
  \mathbb P (C = 1 \mid V = v, E = 0) \times 0.325
  \\
  &\mathbin{\hphantom{=}}
  +
  \mathbb P (C = 1 \mid V = v, E = 1) \times 0.058
  \\
  &\mathbin{\hphantom{=}}
  +
  \mathbb P (C = 1 \mid V = v, E = 2) \times 0.003
\end{align}
$$

where we have used the population frequency of the engagement segments
for $\mathbb P(E = e)$ (see below).

It is easiest to calculate the probability of a click given
non-participation. Amongst users that didn't participate, none clicked.
This implies that the association is 0 regardless of `engagement`, which
in turn implies

$$
\mathbb P(C = 1 \mid \do(V = \text{didn't participate})) = 0
.
$$

The causal effect for other values of $V$ is calculated below. Holding
`engagement` constant, the causal effect of `cohort` in `view` is simply
random sampling, so

$$
\mathbb P (C = 1 \mid \do(\text{Cohort} = c)) = \mathbb P (C = 1 \mid \do(V = c)),
$$

for $c = 0, 1$.

### Causally modelling the data

Let's get data aggregated on the level of `cohort` and `segment`.

``` {.r}
xp <- xp_complete %>% 
  filter(viewed) %>% 
  group_by(cohort, segment) %>% 
  summarise(
    views = n(),
    clicks = sum(clicked)
  ) 
```

We again fit a binomial model but this time include an estimate for the
effect of segment and for the interaction of segment with the cohort.
These extra features are indicated with the `(1 + cohort | segment)`
notation. We did it this way instead of `cohort * segment` in order to
allow [partial
pooling](https://mc-stan.org/users/documentation/case-studies/pool-binary-trials.html)
of estimates, which often improves the quality of estimates in segments
with lower sample sizes (e.g. for the very highly engaged users).

``` {.r}
model <- rstanarm::stan_glmer(
  # binomial test
  cbind(clicks, views - clicks) ~ 1 + cohort + (1 + cohort | segment),
  family = binomial(),
  data = xp,
  # same priors as before
  prior_intercept = prior_intercept,
  prior = prior,
  # MCMC sample sizes
  chains = 4,
  warmup = 1000,
  iter = 5000
)
```

In order to use the backdoor adjustment, we'll need the relative
frequencies of the segments in our general population.

``` {.r}
population <- users %>% 
  group_by(segment) %>% 
  count() %>% 
  ungroup() %>% 
  transmute(segment, weight = n / sum(n))
```

<table class="table table-striped table-hover table-responsive" style="margin-left: auto; margin-right: auto;">
<thead>
<tr>
<th style="text-align:left;">
segment
</th>
<th style="text-align:right;">
weight
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
low
</td>
<td style="text-align:right;">
0.613746
</td>
</tr>
<tr>
<td style="text-align:left;">
medium
</td>
<td style="text-align:right;">
0.324962
</td>
</tr>
<tr>
<td style="text-align:left;">
high
</td>
<td style="text-align:right;">
0.057928
</td>
</tr>
<tr>
<td style="text-align:left;">
very\_high
</td>
<td style="text-align:right;">
0.003364
</td>
</tr>
</tbody>
</table>
Now we can draw our Bayesian posterior estimates, then calculate the CTR
for each cohort by taking the weighted average of CTR across the
segments. Notice that the unobserved population averages now fall well
within the credible intervals.

``` {.r}
xp_draws_adjusted <- xp %>% 
  select(cohort, segment) %>% 
  tidybayes::add_fitted_draws(model) %>% 
  as_tibble() %>% 
  inner_join(population, by = 'segment') %>% 
  mutate(adjusted = .value * weight) %>% 
  group_by(cohort, .draw) %>% 
  summarise(ctr = sum(adjusted)) 
```

![Posterior CTR using causal
model](selection_bias_files/figure-markdown/ctr_adjusted_plot-1..svg)

There is now no need to conduct any test on the difference because the
two variants are so clearly different.

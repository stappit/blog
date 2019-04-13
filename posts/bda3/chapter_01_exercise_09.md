---
always_allow_html: True
author: Brian Callander
date: '2019-04-13'
output:
  md_document:
    preserve_yaml: True
    variant: markdown
tags: 'bda chapter 1, solutions, simulation, poisson process'
title: BDA3 Chapter 1 Exercise 9
tldr: |
    Here's my solution to exercise 9, chapter 1, of Gelman's Bayesian Data
    Analysis (BDA), 3rd edition.
---

Here's my solution to exercise 9, chapter 1, of
[Gelman's](https://andrewgelman.com/) *Bayesian Data Analysis* (BDA),
3rd edition. There are
[solutions](http://www.stat.columbia.edu/~gelman/book/solutions.pdf) to
some of the exercises on the [book's
webpage](http://www.stat.columbia.edu/~gelman/book/).

<!--more-->
<div style="display:none">

$\DeclareMathOperator{\dbinomial}{Binomial}  \DeclareMathOperator{\dbern}{Bernoulli}  \DeclareMathOperator{\dpois}{Poisson}  \DeclareMathOperator{\dnorm}{Normal}  \DeclareMathOperator{\dt}{t}  \DeclareMathOperator{\dcauchy}{Cauchy}  \DeclareMathOperator{\dexponential}{Exp}  \DeclareMathOperator{\duniform}{Uniform}  \DeclareMathOperator{\dgamma}{Gamma}  \DeclareMathOperator{\dinvgamma}{InvGamma}  \DeclareMathOperator{\invlogit}{InvLogit}  \DeclareMathOperator{\logit}{Logit}  \DeclareMathOperator{\ddirichlet}{Dirichlet}  \DeclareMathOperator{\dbeta}{Beta}$

</div>

Suppose there 3 doctors, who open their practice at 09:00 and stop
accepting patients at 16:00. If customers arrive in exponentially
distributed intervals with mean 10 minutes, and appointment duration is
uniformly distributed between 5 and 10 minutes, we want to know:

-   how many patients arrive per day?
-   how many patients have to wait for their appointment?
-   how long do patients have to wait?
-   when does the last patient leave the practice?

We do this by simulation. The `arrivals` function will simulate the
arrival times of the patients, in minutes after 09:00. In principle, we
should simulate draws from the exponential distribution until the sum of
all draws is above 420, the number of minutes the practice accepts
patients. However, I couldn't find any efficient way to run this in R.
Instead we'll draw so many variables such that is is highly unlikely
that we have too few, then just filter out what we don't need.

To calculate a suitably large number, note that the number of patients
in one day is
$\dpois(\frac{1}{10} \cdot (16 - 9) \cdot 60)$-distributed. The
99.99999% percentile of this distribution is
`qpois(0.9999999, (16 - 9) * 6) =` 80. We'll err on the safe side and
use $n=100$.

``` {.r}
arrivals <- function(λ, t, n=100) {
  rexp(n, λ) %>% 
    tibble(
      delay = .,
      time = cumsum(delay)
    ) %>% 
    filter(time <= t) %>% 
    pull(time) %>% 
    return()
}

λ <- 1 / 10
t <- (16 - 9) * 60

arrivals(λ, t)
```

     [1]   8.553171  37.432026  41.871974  49.278030  59.254108  65.324981
     [7]  82.334677  86.637271  87.011499  95.725734 115.382962 127.752763
    [13] 132.191805 144.314143 146.950480 154.842176 165.419482 166.811901
    [19] 188.446479 191.482675 196.825827 205.611658 218.840513 229.112146
    [25] 234.566713 245.715737 247.014959 251.843457 255.886919 270.347635
    [31] 280.522572 283.621836 289.637068 298.571320 315.922588 324.476085
    [37] 325.395870 327.868857 330.081686 331.101767 339.438330 339.777383
    [43] 341.035940 368.511484 368.530882 380.830336 382.230143 386.228364
    [49] 389.420076 403.214854 409.342300 413.720262

Given the patients that arrive in a day, we now need a function to
simulate the appointments. Let's assume the patients get seen in the
order they arrive. As we cycle through the patients, we'll keep track of

-   `n_waited`, the number of patients who have had to wait for their
    appointment so far;
-   `time_waiting`, the sum of all waiting times of the patients so far;
    and
-   `doctors`, the next time at which each doctor is free to see another
    patient.

The `doctors` variable starts at `c(0, 0, 0)` because they are
immediately availble to see patients. The doctor with the smallest
availability time is the next doctor to see a patient. The start of the
appointment is either the doctor's availability time or the arrival time
of the patient, whichever is greater. The end of the appointment is
$\duniform(5, 20)$-minutes after the start of the appointment. The
doctor's availability time is then set to the end of the appointment.
Once all patients have been given an appointment, the closing time is
the maximum of the doctors' next availability times or the closing time
`(16 - 9) * 60`, whichever is greater.

``` {.r}
process <- function(arrivals, t=0) {
  
  n_waited <- 0         # number of patients who have had to wait so far
  time_waiting <- 0     # total waiting time so far
  doctors <- c(0, 0, 0) # next time at which each doctor is free to see another patient
  
  for(i in (1:length(arrivals))) {
    wait <- pmax(min(doctors) - arrivals[i], 0) # waiting time of patient i
    time_waiting <- time_waiting + wait
    n_waited <- n_waited + (wait > 0)
    appointment_start <- max(c(min(doctors), arrivals[i]))
    appointment_end <- appointment_start + runif(1, 5, 20)
    doctors[which.min(doctors)] <- appointment_end
  }
  
  list(
    n_patients = length(arrivals),
    n_waited = n_waited,
    time_waiting = time_waiting,
    time_waiting_per_patient = time_waiting / length(arrivals),
    time_waiting_per_waiting_patient = time_waiting / n_waited,
    closing_time = pmax(max(doctors), t)
  ) %>% return()
    
}

arrivals(λ, t) %>% 
  process(t)
```

    $n_patients
    [1] 33

    $n_waited
    [1] 0

    $time_waiting
    [1] 0

    $time_waiting_per_patient
    [1] 0

    $time_waiting_per_waiting_patient
    [1] NaN

    $closing_time
    [1] 425.9203

To simulate the above many times, we'll use the `replicate` function.
For convenience, we'll turn this into a `tibble`.

``` {.r}
simulate <- function(iters, λ, t, n=100) {
  iters %>% 
    replicate(process(arrivals(λ, t, n), t)) %>% 
    t() %>% 
    as_tibble() %>% 
    mutate_all(unlist)
}

sims <- simulate(1000, λ, t)
```

<table class="table table-striped table-hover table-responsive" style="margin-left: auto; margin-right: auto;">
<caption>
The first few simulations of a day at the practice.
</caption>
<thead>
<tr>
<th style="text-align:right;">
n\_patients
</th>
<th style="text-align:right;">
n\_waited
</th>
<th style="text-align:right;">
time\_waiting
</th>
<th style="text-align:right;">
closing\_time
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:right;">
36
</td>
<td style="text-align:right;">
5
</td>
<td style="text-align:right;">
7.849097
</td>
<td style="text-align:right;">
428.0292
</td>
</tr>
<tr>
<td style="text-align:right;">
25
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:right;">
0.000000
</td>
<td style="text-align:right;">
420.0000
</td>
</tr>
<tr>
<td style="text-align:right;">
43
</td>
<td style="text-align:right;">
12
</td>
<td style="text-align:right;">
68.185313
</td>
<td style="text-align:right;">
424.2967
</td>
</tr>
<tr>
<td style="text-align:right;">
45
</td>
<td style="text-align:right;">
4
</td>
<td style="text-align:right;">
6.891720
</td>
<td style="text-align:right;">
425.0424
</td>
</tr>
<tr>
<td style="text-align:right;">
38
</td>
<td style="text-align:right;">
4
</td>
<td style="text-align:right;">
13.346805
</td>
<td style="text-align:right;">
429.7816
</td>
</tr>
<tr>
<td style="text-align:right;">
44
</td>
<td style="text-align:right;">
8
</td>
<td style="text-align:right;">
51.054677
</td>
<td style="text-align:right;">
424.8640
</td>
</tr>
</tbody>
</table>
Finally, we can calculate the 50% intervals by applying the `quantile`
function to each summary.

``` {.r}
sims_summary <- sims %>% 
  gather(variable, value) %>% 
  group_by(variable) %>% 
  summarise(
    q25 = quantile(value, 0.25, na.rm=TRUE),
    q50 = quantile(value, 0.5, na.rm=TRUE),
    q75 = quantile(value, 0.75, na.rm=TRUE),
    simulations = n()
  )
```

<table class="table table-striped table-hover table-responsive" style="margin-left: auto; margin-right: auto;">
<caption>
The median and 50% interval for each summary statistic.
</caption>
<thead>
<tr>
<th style="text-align:left;">
variable
</th>
<th style="text-align:right;">
q25
</th>
<th style="text-align:right;">
q50
</th>
<th style="text-align:right;">
q75
</th>
<th style="text-align:right;">
simulations
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
closing\_time
</td>
<td style="text-align:right;">
420.000000
</td>
<td style="text-align:right;">
426.24414
</td>
<td style="text-align:right;">
431.45153
</td>
<td style="text-align:right;">
1000
</td>
</tr>
<tr>
<td style="text-align:left;">
n\_patients
</td>
<td style="text-align:right;">
37.000000
</td>
<td style="text-align:right;">
42.00000
</td>
<td style="text-align:right;">
46.00000
</td>
<td style="text-align:right;">
1000
</td>
</tr>
<tr>
<td style="text-align:left;">
n\_waited
</td>
<td style="text-align:right;">
3.000000
</td>
<td style="text-align:right;">
5.00000
</td>
<td style="text-align:right;">
9.00000
</td>
<td style="text-align:right;">
1000
</td>
</tr>
<tr>
<td style="text-align:left;">
time\_waiting
</td>
<td style="text-align:right;">
8.920944
</td>
<td style="text-align:right;">
20.48693
</td>
<td style="text-align:right;">
38.40291
</td>
<td style="text-align:right;">
1000
</td>
</tr>
</tbody>
</table>

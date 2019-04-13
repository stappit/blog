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

     [1]   4.854265   4.963889   6.651014   9.518990  17.415709  20.110178
     [7]  28.852188  34.862538  35.970215  44.205468  48.342152  52.934693
    [13]  83.072579  86.746318 117.586517 122.811176 133.662687 142.016603
    [19] 170.935913 190.999325 202.511439 204.915770 205.191951 208.422873
    [25] 219.437526 225.162971 233.122550 235.351649 253.558658 254.097711
    [31] 255.639118 256.270049 277.905899 291.055504 291.737173 294.688419
    [37] 300.949679 302.681417 329.751112 335.998940 355.506712 361.162687
    [43] 381.436543 388.767558 393.072689 393.088807 395.570811 401.669343
    [49] 401.911643 408.650710 418.291196

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
    [1] 39

    $n_waited
    [1] 0

    $time_waiting
    [1] 0

    $time_waiting_per_patient
    [1] 0

    $time_waiting_per_waiting_patient
    [1] NaN

    $closing_time
    [1] 426.9273

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
time\_waiting\_per\_patient
</th>
<th style="text-align:right;">
time\_waiting\_per\_waiting\_patient
</th>
<th style="text-align:right;">
closing\_time
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:right;">
45
</td>
<td style="text-align:right;">
8
</td>
<td style="text-align:right;">
10.493347
</td>
<td style="text-align:right;">
0.2331855
</td>
<td style="text-align:right;">
1.311668
</td>
<td style="text-align:right;">
421.2221
</td>
</tr>
<tr>
<td style="text-align:right;">
44
</td>
<td style="text-align:right;">
6
</td>
<td style="text-align:right;">
13.226377
</td>
<td style="text-align:right;">
0.3005995
</td>
<td style="text-align:right;">
2.204396
</td>
<td style="text-align:right;">
435.4524
</td>
</tr>
<tr>
<td style="text-align:right;">
29
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
1.174172
</td>
<td style="text-align:right;">
0.0404887
</td>
<td style="text-align:right;">
1.174172
</td>
<td style="text-align:right;">
435.9763
</td>
</tr>
<tr>
<td style="text-align:right;">
31
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
9.413756
</td>
<td style="text-align:right;">
0.3036696
</td>
<td style="text-align:right;">
9.413756
</td>
<td style="text-align:right;">
440.1210
</td>
</tr>
<tr>
<td style="text-align:right;">
40
</td>
<td style="text-align:right;">
5
</td>
<td style="text-align:right;">
16.692607
</td>
<td style="text-align:right;">
0.4173152
</td>
<td style="text-align:right;">
3.338521
</td>
<td style="text-align:right;">
431.8950
</td>
</tr>
<tr>
<td style="text-align:right;">
37
</td>
<td style="text-align:right;">
2
</td>
<td style="text-align:right;">
11.329963
</td>
<td style="text-align:right;">
0.3062152
</td>
<td style="text-align:right;">
5.664981
</td>
<td style="text-align:right;">
420.0000
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
424.9488049
</td>
<td style="text-align:right;">
430.7023807
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
38.000000
</td>
<td style="text-align:right;">
42.0000000
</td>
<td style="text-align:right;">
46.2500000
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
5.0000000
</td>
<td style="text-align:right;">
9.0000000
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
8.266744
</td>
<td style="text-align:right;">
19.3983242
</td>
<td style="text-align:right;">
38.9367142
</td>
<td style="text-align:right;">
1000
</td>
</tr>
<tr>
<td style="text-align:left;">
time\_waiting\_per\_patient
</td>
<td style="text-align:right;">
0.212705
</td>
<td style="text-align:right;">
0.4685262
</td>
<td style="text-align:right;">
0.8622254
</td>
<td style="text-align:right;">
1000
</td>
</tr>
<tr>
<td style="text-align:left;">
time\_waiting\_per\_waiting\_patient
</td>
<td style="text-align:right;">
2.660497
</td>
<td style="text-align:right;">
3.8266619
</td>
<td style="text-align:right;">
5.1309744
</td>
<td style="text-align:right;">
1000
</td>
</tr>
</tbody>
</table>

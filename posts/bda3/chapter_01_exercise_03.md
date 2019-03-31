---
always_allow_html: True
author: Brian Callander
date: '2019-03-31'
output:
  md_document:
    preserve_yaml: True
    variant: markdown
tags: 'bda chapter 1, solutions, hardy-weinberg principle'
title: BDA3 Chapter 1 Exercise 3
tldr: |
    Here's my solution to exercise 3, chapter 1, of Gelman's Bayesian Data
    Analysis (BDA), 3rd edition.
---

Here's my solution to exercise 3, chapter 1, of
[Gelman's](https://andrewgelman.com/) *Bayesian Data Analysis* (BDA),
3rd edition. There are
[solutions](http://www.stat.columbia.edu/~gelman/book/solutions.pdf) to
some of the exercises on the [book's
webpage](http://www.stat.columbia.edu/~gelman/book/).

<!--more-->
<div style="display:none">

$\DeclareMathOperator{\dbinomial}{Binomial}  \DeclareMathOperator{\dbern}{Bernoulli}  \DeclareMathOperator{\dpois}{Poisson}  \DeclareMathOperator{\dnorm}{Normal}  \DeclareMathOperator{\dt}{t}  \DeclareMathOperator{\dcauchy}{Cauchy}  \DeclareMathOperator{\dexponential}{Exp}  \DeclareMathOperator{\duniform}{Uniform}  \DeclareMathOperator{\dgamma}{Gamma}  \DeclareMathOperator{\dinvgamma}{InvGamma}  \DeclareMathOperator{\invlogit}{InvLogit}  \DeclareMathOperator{\logit}{Logit}  \DeclareMathOperator{\ddirichlet}{Dirichlet}  \DeclareMathOperator{\dbeta}{Beta}$

</div>

Suppose a particular gene for eye colour has two alleles: a dominant X
and a recessive x allele. Having $xx$ gives you blue eyes, otherwise you
have brown eyes. Suppose also that the proportion of blue-eyed people is
$p^2$, and the proportion of heterozygotes is $2p(1 - p)$. There are 3
questions to answer:

1.  What is the probability of a brown-eyed child of brown-eyed parents
    being a heterozygote?
2.  If such a heterozygote, Judy, has n brown-eyed children with a
    random heterozygote, what's the probability that Judy is a
    heterozygote?
3.  Under the conditions of part 2, what is the probability that Judy's
    first grandchild has blue eyes?

Simulation
----------

Let's first set up some data with which we can verify the results via
simulation.

### Data

We'll simulate a large population of individuals where the probability
of the recessive allele is 0.2.

``` {.r}
set.seed(11146)

N <- 5000000
p <- 0.2

alleles <- c('x', 'X')
weights <- c(p, 1 - p)

df <- tibble(id = 1:N %>% as.character()) %>% 
  mutate(
    allele1 = sample(alleles, N, prob = weights, replace = TRUE),
    allele2 = sample(alleles, N, prob = weights, replace = TRUE),
    genotype = if_else(allele1 == allele2, 'homozygote', 'heterozygote'),
    eye_colour = if_else(allele1 == 'x' & allele2 == 'x', 'blue', 'brown')
  ) 
```

<table class="table table-striped table-hover table-responsive" style="margin-left: auto; margin-right: auto;">
<thead>
<tr>
<th style="text-align:left;">
id
</th>
<th style="text-align:left;">
allele1
</th>
<th style="text-align:left;">
allele2
</th>
<th style="text-align:left;">
genotype
</th>
<th style="text-align:left;">
eye\_colour
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
X
</td>
<td style="text-align:left;">
X
</td>
<td style="text-align:left;">
homozygote
</td>
<td style="text-align:left;">
brown
</td>
</tr>
<tr>
<td style="text-align:left;">
2
</td>
<td style="text-align:left;">
x
</td>
<td style="text-align:left;">
X
</td>
<td style="text-align:left;">
heterozygote
</td>
<td style="text-align:left;">
brown
</td>
</tr>
<tr>
<td style="text-align:left;">
3
</td>
<td style="text-align:left;">
X
</td>
<td style="text-align:left;">
x
</td>
<td style="text-align:left;">
heterozygote
</td>
<td style="text-align:left;">
brown
</td>
</tr>
<tr>
<td style="text-align:left;">
4
</td>
<td style="text-align:left;">
X
</td>
<td style="text-align:left;">
X
</td>
<td style="text-align:left;">
homozygote
</td>
<td style="text-align:left;">
brown
</td>
</tr>
<tr>
<td style="text-align:left;">
5
</td>
<td style="text-align:left;">
x
</td>
<td style="text-align:left;">
X
</td>
<td style="text-align:left;">
heterozygote
</td>
<td style="text-align:left;">
brown
</td>
</tr>
<tr>
<td style="text-align:left;">
6
</td>
<td style="text-align:left;">
X
</td>
<td style="text-align:left;">
X
</td>
<td style="text-align:left;">
homozygote
</td>
<td style="text-align:left;">
brown
</td>
</tr>
</tbody>
</table>
This has the correct distribution of alleles, since $p^2 \approx$ 0.04
and $(1-p)^2\approx$ 0.64.

``` {.r}
allele_distribution <- df %>%
  group_by(allele1, allele2) %>%
  tally() %>%
  mutate(frac = n / sum(n))
```

<table class="table table-striped table-hover table-responsive" style="margin-left: auto; margin-right: auto;">
<thead>
<tr>
<th style="text-align:left;">
allele1
</th>
<th style="text-align:left;">
allele2
</th>
<th style="text-align:right;">
n
</th>
<th style="text-align:right;">
frac
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
x
</td>
<td style="text-align:left;">
x
</td>
<td style="text-align:right;">
200006
</td>
<td style="text-align:right;">
0.2000018
</td>
</tr>
<tr>
<td style="text-align:left;">
x
</td>
<td style="text-align:left;">
X
</td>
<td style="text-align:right;">
800015
</td>
<td style="text-align:right;">
0.7999982
</td>
</tr>
<tr>
<td style="text-align:left;">
X
</td>
<td style="text-align:left;">
x
</td>
<td style="text-align:right;">
800802
</td>
<td style="text-align:right;">
0.2002016
</td>
</tr>
<tr>
<td style="text-align:left;">
X
</td>
<td style="text-align:left;">
X
</td>
<td style="text-align:right;">
3199177
</td>
<td style="text-align:right;">
0.7997984
</td>
</tr>
</tbody>
</table>
This also has the correct distribution of eye colours.

``` {.r}
eye_colour_distribution <- df %>%
  group_by(eye_colour) %>%
  tally() %>%
  mutate(frac = n / sum(n))
```

<table class="table table-striped table-hover table-responsive" style="margin-left: auto; margin-right: auto;">
<thead>
<tr>
<th style="text-align:left;">
eye\_colour
</th>
<th style="text-align:right;">
n
</th>
<th style="text-align:right;">
frac
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
blue
</td>
<td style="text-align:right;">
200006
</td>
<td style="text-align:right;">
0.0400012
</td>
</tr>
<tr>
<td style="text-align:left;">
brown
</td>
<td style="text-align:right;">
4799994
</td>
<td style="text-align:right;">
0.9599988
</td>
</tr>
</tbody>
</table>
The genotype distribution is also correct, since $2p(1-p) \approx$ 0.32.

``` {.r}
genotype_distribution <- df %>%
  group_by(genotype) %>%
  tally() %>%
  mutate(frac = n / sum(n))
```

<table class="table table-striped table-hover table-responsive" style="margin-left: auto; margin-right: auto;">
<thead>
<tr>
<th style="text-align:left;">
genotype
</th>
<th style="text-align:right;">
n
</th>
<th style="text-align:right;">
frac
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
heterozygote
</td>
<td style="text-align:right;">
1600817
</td>
<td style="text-align:right;">
0.3201634
</td>
</tr>
<tr>
<td style="text-align:left;">
homozygote
</td>
<td style="text-align:right;">
3399183
</td>
<td style="text-align:right;">
0.6798366
</td>
</tr>
</tbody>
</table>
### Reproduction

Let's also define a couple of functions to simulate reproduction within
our population. The `pair` function matches up random individuals from
the first table with random individuals from the second.

``` {.r}
pair <- function(df1, df2) {
  inner_join(
      df1 %>%
        select(-matches('\\.(x|y)$')) %>%
        select(matches('^(id|allele|genotype|eye)')) %>%
        ungroup() %>%
        sample_frac(size = 1) %>%
        mutate(row = row_number()),
      df2 %>%
        select(-matches('\\.(x|y)$')) %>%
        select(matches('^(id|allele|genotype|eye)')) %>%
        ungroup() %>%
        sample_frac(size = 1) %>%
        mutate(row = row_number()),
      by = 'row'
    ) %>%
    select(-row) %>%
    return()
}
```

The `reproduce` function then randomly generates a child from the paired
individuals.

``` {.r}
reproduce <- function(pairs, n=1) {
  pairs %>%
    crossing(child = 1:n) %>% 
    mutate(
      # the variables x and y indicate the allele taken from parent x and y, respectively
      x = rbinom(n(), 1, 0.5) + 1,
      y = rbinom(n(), 1, 0.5) + 1,
      allele1 = if_else(x == 1, allele1.x, allele2.x),
      allele2 = if_else(y == 1, allele1.y, allele2.y),
      genotype = if_else(allele1 == allele2, 'homozygote', 'heterozygote'),
      eye_colour = if_else(allele1 == 'x' & allele2 == 'x', 'blue', 'brown'),
      id = paste(id.x, id.y, child, sep = '-')
    ) %>%
    return()
}
```

The `kids` table then represents the next generation from random mating
within the entire population.

``` {.r}
kids <- df %>%
  pair(df) %>% 
  reproduce()
```

<table class="table table-striped table-hover table-responsive" style="margin-left: auto; margin-right: auto;">
<thead>
<tr>
<th style="text-align:left;">
allele1.x
</th>
<th style="text-align:left;">
allele2.x
</th>
<th style="text-align:left;">
allele1.y
</th>
<th style="text-align:left;">
allele2.y
</th>
<th style="text-align:left;">
allele1
</th>
<th style="text-align:left;">
allele2
</th>
<th style="text-align:right;">
x
</th>
<th style="text-align:right;">
y
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
X
</td>
<td style="text-align:left;">
X
</td>
<td style="text-align:left;">
X
</td>
<td style="text-align:left;">
x
</td>
<td style="text-align:left;">
X
</td>
<td style="text-align:left;">
X
</td>
<td style="text-align:right;">
2
</td>
<td style="text-align:right;">
1
</td>
</tr>
<tr>
<td style="text-align:left;">
X
</td>
<td style="text-align:left;">
x
</td>
<td style="text-align:left;">
X
</td>
<td style="text-align:left;">
X
</td>
<td style="text-align:left;">
x
</td>
<td style="text-align:left;">
X
</td>
<td style="text-align:right;">
2
</td>
<td style="text-align:right;">
1
</td>
</tr>
<tr>
<td style="text-align:left;">
X
</td>
<td style="text-align:left;">
X
</td>
<td style="text-align:left;">
X
</td>
<td style="text-align:left;">
x
</td>
<td style="text-align:left;">
X
</td>
<td style="text-align:left;">
x
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
2
</td>
</tr>
<tr>
<td style="text-align:left;">
X
</td>
<td style="text-align:left;">
X
</td>
<td style="text-align:left;">
X
</td>
<td style="text-align:left;">
X
</td>
<td style="text-align:left;">
X
</td>
<td style="text-align:left;">
X
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
1
</td>
</tr>
<tr>
<td style="text-align:left;">
X
</td>
<td style="text-align:left;">
x
</td>
<td style="text-align:left;">
X
</td>
<td style="text-align:left;">
x
</td>
<td style="text-align:left;">
X
</td>
<td style="text-align:left;">
X
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
1
</td>
</tr>
<tr>
<td style="text-align:left;">
x
</td>
<td style="text-align:left;">
X
</td>
<td style="text-align:left;">
X
</td>
<td style="text-align:left;">
X
</td>
<td style="text-align:left;">
x
</td>
<td style="text-align:left;">
X
</td>
<td style="text-align:right;">
1
</td>
<td style="text-align:right;">
1
</td>
</tr>
</tbody>
</table>
The parent attributes are contained in the `kids` table, with the `.x`
suffix for one parent and `.y` for the other.

Part 1
------

We'll use $A$ to stand for the allele combination, e.g. $XX$, or
$Xx = xX$, and $E$ for eye colour. The subscripts $i = 1, 2$ will be
used for each of the two parents, and the absence of subscripts will
indicate the variable for the child. We need to calculate the
probability that the child is heterogenous given that they are
brown-eyed with brown-eyed parents:

$$
\mathbb P (A = Xx \mid E, E_1, E_2 = B).
$$

It will be easier to calculate this if we can rewrite it as a
probability conditional only on $A_\bullet$-variables. First note that

$$
\begin{align}
  \mathbb P (A, A_1, A_2)
  &=
  \mathbb P (A \mid A_1, A_2) \mathbb P(A_1, A_2)
  \\
  &=
  \mathbb P (A \mid A_1, A_2) \mathbb P(A_1) \mathbb P (A_2)
\end{align}
$$

using the chain rule and the assumption of random mating. Therefore,

$$
\begin{align}
  &
  P (A = Xx \mid E_\bullet = B)
  \\
  &=
  \frac{\mathbb P (E_\bullet = B \mid A = Xx) \cdot \mathbb P (A = Xx)}{\mathbb P (E_\bullet = B)}
  \\
  &=
  \frac{
    \sum_{a_1, a_2} \mathbb P (E_\bullet = B \mid A = Xx, A_1 = a_1, A_2 = a_2) \cdot \mathbb P (A = Xx \mid A_1 = a_1, A_2 = a_2) \cdot \mathbb P (A_1 = a_1) \cdot \mathbb P (A_2 = a_2)
  }{
    \sum_{a, a_1, a_2} \mathbb P (E_\bullet = B \mid A = a, A_1 = a_1, A_2 = a_2) \cdot \mathbb P (A = a \mid A_1 = a_1, A_2 = a_2) \cdot \mathbb P (A_1 = a_1) \cdot \mathbb P (A_2 = a_2)
  },
\end{align}
$$

where the numerator is marginalised over possible values of $A_1$ and
$A_2$, and the denominator additionally over $A$.

The factors involving $E_\bullet$ are either 1 or 0, depending only on
whether the given combination of alleles can give rise to brown eyes or
not, respectively. Moreover, $\mathbb P (A_i = XX) = (1 - p)^2$ and
$\mathbb P (A_i = Xx) = 2p(1 - p)$, where the case $A_i = xx$ is
impossible conditional on everybody having brown eyes. The only
non-trivial calculations now involve
$\mathbb P (A = a \mid A_1 = a_1, A_2 = a_2)$:

$$
\begin{align}
  \mathbb P (A = Xx \mid A_1 = Xx, A_2 = Xx)
  &=
  \frac{1}{2}
  \\
  \mathbb P (A = Xx \mid A_1 = Xx, A_2 = XX)
  &=
  \frac{1}{2}
  \\
  \mathbb P (A = Xx \mid A_1 = XX, A_2 = XX)
  &=
  0
  \\
  \mathbb P (A = XX \mid A_1 = Xx, A_2 = Xx)
  &=
  \frac{1}{4}
  \\
  \mathbb P (A = XX \mid A_1 = Xx, A_2 = XX)
  &=
  \frac{1}{2}
  \\
  \mathbb P (A = XX \mid A_1 = XX, A_2 = XX)
  &=
  1,
\end{align}
$$

as can be verified by inspection.

Now let's plug in these values into the formula for the desired
probability. The numerator is

$$
\begin{align}
  &
  P (A = Xx \mid E_\bullet = B)
  \\
  &=
  \frac{
    \frac{1}{2} \cdot (2p(1 - p))^2 
    + \frac{1}{2} \cdot 2 \cdot 2p(1 - p)(1 - p)^2
    + 0 \cdot (1 - p)^4
  }{
    (\frac{1}{2} + \frac{1}{4}) \cdot 4p^2(1 - p)^2 
    + (\frac{1}{2} + \frac{1}{2}) \cdot 4p(1 - p)^3
    + (0 + 1) \cdot (1 - p)^4
  }
  \\
  &=
  \frac{(1 - p)^2}{(1 - p)^2}
  \frac{
    2p^2 + 2p(1 - p)
  }{
    3p^2 + 4p(1 - p) + (1 - p)^2
  }
  \\
  &=
  \frac{
    2p^2 + 2p - 2p^2
  }{
    3p^2 + 4p - 4p^2 + 1 + p^2 - 2p
  }
  \\
  &=
  \frac{
    2p
  }{
    1 + 2p
  },
\end{align}
$$

as required. This is approximately $2p$ for small $p$, and is
approximatily $\frac{1}{2}$ for large $p$.

Part 1 simulation
-----------------

To condition on brown-eyed children from brown-eyed parents, we can just
filter the `kids` table. Such a child is called `judy` in this exercise.

``` {.r}
judy <- kids %>%
  filter(
    eye_colour.x == 'brown',
    eye_colour.y == 'brown',
    eye_colour   == 'brown'
  )

judy_genotypes <- judy %>%
  group_by(genotype) %>%
  tally() %>%
  mutate(frac = n / sum(n))
```

<table class="table table-striped table-hover table-responsive" style="margin-left: auto; margin-right: auto;">
<thead>
<tr>
<th style="text-align:left;">
genotype
</th>
<th style="text-align:right;">
n
</th>
<th style="text-align:right;">
frac
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
heterozygote
</td>
<td style="text-align:right;">
1280529
</td>
<td style="text-align:right;">
0.2858268
</td>
</tr>
<tr>
<td style="text-align:left;">
homozygote
</td>
<td style="text-align:right;">
3199559
</td>
<td style="text-align:right;">
0.7141732
</td>
</tr>
</tbody>
</table>
This is very close to the theoretical value of
$\frac{2p}{1 + 2p}\approx$ 0.286.

Part 2
------

Denote by $E_{C_\bullet} = B$ the condition that all of Judy's children
have brown eyes, and by $A^p = a$ the condition that Judy's partner has
allele combination $a$. Then

$$
\begin{align}
  &
  \mathbb P (A = Xx \mid E_\bullet = B = E_{C_\bullet}, A^p = Xx)
  \\
  &=
  \frac{
    \mathbb P (A = Xx \mid E_\bullet = B, A^p = Xx)
    \cdot
    \mathbb P (E_{C_\bullet} = B \mid E_\bullet = B, A^p = Xx = A)
  }{
    \mathbb P (E_{C_\bullet} = B \mid E_\bullet = B, A^p = Xx)
  }
  \\
  &=
  \frac{
    \mathbb P (A = Xx \mid E_\bullet = B)
    \cdot
    \mathbb P (E_{C_\bullet} = B \mid A^p = Xx = A)
  }{
    \sum_a 
    \mathbb P (E_{C_\bullet} = B \mid E_\bullet = B, A^p = Xx, A = a) 
    \cdot
    \mathbb P (A = a \mid E_\bullet = B, A^p = Xx)
  }
  \\
  &=
  \frac{
    \mathbb P (A = Xx \mid E_\bullet = B)
    \cdot
    \mathbb P (E_{C_\bullet} = B \mid A^p = Xx = A)
  }{
    \sum_a 
    \mathbb P (E_{C_\bullet} = B \mid A^p = Xx, A = a) 
    \cdot
    \mathbb P (A = a \mid E_\bullet = B)
  }
  \\
  &=
  \frac{
    \frac{2p}{1 + 2p}
    \cdot
    (\frac{3}{4})^n
  }{
    \mathbb P (E_{C_\bullet} = B \mid A^p = Xx = A) 
    \cdot
    \mathbb P (A = Xx \mid E_\bullet = B)
    +
    \mathbb P (E_{C_\bullet} = B \mid A^p = Xx, A = XX) 
    \cdot
    \mathbb P (A = XX \mid E_\bullet = B)
  }
  \\
  &=
  \frac{
    \frac{2p}{1 + 2p}
    \cdot
    (\frac{3}{4})^n
  }{
    \frac{2p}{1 + 2p}
    \cdot
    (\frac{3}{4})^n
    +
    \frac{1}{1 + 2p}
  }
  \\
  &=
  \frac{2p \cdot (\frac{3}{4})^n}{2p \cdot (\frac{3}{4})^n + 1}
  \\
  &=
  \frac{2p \cdot 3^n}{2p \cdot 3^n + 4^n}
  ,
\end{align}
$$

where we have used conditional independence several times for the
probability of the child's alleles given the parents' alleles. As
$n \rightarrow \infty$, this probability shrinks to 0.

Part 2 simulation
-----------------

To simulate part 2, we need to pair `judy` with heterozygotes from the
general population, then filter for those children with brown eyes.

``` {.r}
judy_kids <- df %>%
  filter(genotype == 'heterozygote') %>%
  pair(judy) %>% 
  reproduce() %>% 
  ungroup() %>% 
  filter(eye_colour == 'brown')
```

Amongst `judy_kids`, Judy's attributes have the `.y` suffix. Given the
above conditions, the probability of her possible genotypes are then:

``` {.r}
judy_genotypes_posterior <- judy_kids %>%
  group_by(genotype.y) %>% 
  tally() %>% 
  mutate(frac = n / sum(n))
```

<table class="table table-striped table-hover table-responsive" style="margin-left: auto; margin-right: auto;">
<thead>
<tr>
<th style="text-align:left;">
genotype.y
</th>
<th style="text-align:right;">
n
</th>
<th style="text-align:right;">
frac
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
heterozygote
</td>
<td style="text-align:right;">
343962
</td>
<td style="text-align:right;">
0.2313911
</td>
</tr>
<tr>
<td style="text-align:left;">
homozygote
</td>
<td style="text-align:right;">
1142534
</td>
<td style="text-align:right;">
0.7686089
</td>
</tr>
</tbody>
</table>
This is close to the theoretical value of $\frac{6p}{6p + 4}\approx$
23.1%.

Part 3
------

Let's introduce some notation. Let $A_g$ be the alleles of Judy's first
grandchild, the child of $c$ with alleles $A_c$ whose partner has
alleles $A_c^p$. We wish to calculate
$\mathbb P (A_g = xx \mid E_\bullet = B = E_{C_\bullet}, A^p = Xx)$.

First note that

\$\$
\begin{align}
  &
  \mathbb P (A_c = Xx \mid E_\bullet = E_{C_\bullet} = B, A^p = Xx, A = a)
  \\
  &=
  \frac{
    \mathbb P (E_{C_\bullet} = B \mid E_\bullet = B, A_c = Xx = A^p, A = a)
    \cdot
    \mathbb P (A_c = Xx \mid E_\bullet = B, A^p = Xx, A = a, A)
  }{
    \mathbb P (E_{C_\bullet} = B \mid E_\bullet = B, A^p = Xx, A = a)
  }
  \\
  &=
  \frac{
    \mathbb P (E_{C_\bullet} = B \mid E_\bullet = B, A_c = Xx = A^p, A = a)
    \cdot
    0.5
  }{
    \mathbb P (E_{C_\bullet} = B \mid E_\bullet = B, A^p = Xx, A = a)
  }
  \\
  &=
  \begin{cases}
    \frac{\left(\frac{3}{4}\right)^{n-1} \cdot \frac{1}{2}}{\left(\frac{3}{4}\right)^n}
    &\text{if } A = Xx
    \\
    1 \cdot \frac{1}{2} / 1
    &\text{othewrise}
    
  \end{cases}
  \\
  &=
  \begin{cases}
    \frac{2}{3}
    &\text{if } A = Xx
    \\
    \frac{1}{2}
    &\text{othewrise}
    
  \end{cases}
  .
\end{align}
\$\$

Thus,

\$\$
\begin{align}
  &
  \mathbb P (A_c = Xx \mid E_\bullet = B = E_{C_\bullet}, A^p = Xx)
  \\
  &=
  \sum_a
  \mathbb P (A_c = Xx \mid E_\bullet = B = E_{C_\bullet}, A^p = Xx, A = a) 
  \cdot
  \mathbb P (A = a \mid E_\bullet = B = E_{C_\bullet}, A^p = Xx) 
  \\
  &=
  \frac{2}{3} \cdot 
  \frac{2p \cdot (\frac{3}{4})^n}{2p \cdot (\frac{3}{4})^n + 1}
  +
  \frac{1}{2} \cdot 
  \frac{1}{2p \cdot (\frac{3}{4})^n + 1}

  \\
  &=
  \frac{p\left( \frac{3}{4} \right)^{n-1} + 0.5}{2p \cdot \left(\frac{3}{4}\right)^n + 1}
  ,
\end{align}
\$\$

which converges to $\frac{1}{2}$ as $n \rightarrow \infty$.

The probability that Judy's first grandchild is a homozygote can then be
calculated by marginalising over the allele combinations of the child
and their partner:

\$\$
\begin{align}
  &
  \mathbb P (A_g = xx \mid E_\bullet = B = E_{C_\bullet}, A^p = Xx)
  \\
  &=
  \sum_{a_c, a_c^p} 
  \mathbb P (A_g = xx \mid E_\bullet = B = E_{C_\bullet}, A^p = Xx, A_c = a_c, A_c^p = a_c^p) 
  \cdot 
  \mathbb P (A_c = a_c, A_c^p = a_c^p \mid E_\bullet = B = E_{C_\bullet}, A^p = Xx)
  \\
  &=
  \sum_{a_c, a_c^p} 
  \mathbb P (A_g = xx \mid A_c = a_c, A_c^p = a_c^p) 
  \cdot 
  \mathbb P (A_c^p = a_c^p )
  \cdot 
  \mathbb P (A_c = a_c \mid E_\bullet = B = E_{C_\bullet}, A^p = Xx)
  \\
  &=
  \sum_{a_c^p} 
  \mathbb P (A_g = xx \mid A_c = Xx, A_c^p = a_c^p) 
  \cdot 
  \mathbb P (A_c^p = a_c^p )
  \cdot 
  \mathbb P (A_c = Xx \mid E_\bullet = B = E_{C_\bullet}, A^p = Xx)
  
  \\
  &=
  
  \frac{p\left( \frac{3}{4} \right)^{n-1} + 0.5}{2p \cdot \left(\frac{3}{4}\right)^n + 1}
  \cdot 
  \sum_{a_c^p} 
  \mathbb P (A_g = xx \mid A_c = Xx, A_c^p = a_c^p) 
  \cdot 
  \mathbb P (A_c^p = a_c^p )
  
  \\
  &=
  
  \frac{p\left( \frac{3}{4} \right)^{n-1} + 0.5}{2p \cdot \left(\frac{3}{4}\right)^n + 1}
  \cdot 
  \left(
  \mathbb P (A_g = xx \mid A_c = Xx, A_c^p = Xx) 
  \cdot 
  \mathbb P (A_c^p = Xx )
  +
  \mathbb P (A_g = xx \mid A_c = Xx, A_c^p = xx) 
  \cdot 
  \mathbb P (A_c^p = xx )
  \right)
  
  \\
  &=
  
  \frac{p\left( \frac{3}{4} \right)^{n-1} + 0.5}{2p \cdot \left(\frac{3}{4}\right)^n + 1}
  \cdot 
  \left(
  \frac{1}{4}
  \cdot 
  2p(1 - p)
  +
  \frac{1}{2}
  \cdot 
  p^2
  \right)
  
  \\
  &=
  
  \frac{p\left( \frac{3}{4} \right)^{n-1} + 0.5}{2p \cdot \left(\frac{3}{4}\right)^n + 1}
  \cdot
  \frac{p}{2}
  ,
\end{align}
\$\$

since

-   the grandchild can only be blue-eyed if the (brown-eyed) child has
    at least one x-allele, i.e. the child is $Xx$;

-   $A$ and $A^p$ are independent by the random mating assumption; and

-   $A_c$ and $A_c^p$ are independent by the random mating assumption.

As $n \rightarrow \infty$, this probability converges to $\frac{p}{4}$.

Part 3 simulation
-----------------

To simulate Judy's grandkids, we pair up `judy_kids` with members of the
general population.

``` {.r}
judy_grandkids <- judy_kids %>% 
  pair(df) %>% 
  reproduce()

judy_grandkids %>% 
  summarise(mean(eye_colour == 'blue')) %>% 
  pull() %>% 
  signif(3)
```

    [1] 0.054

The above fraction of grandkids with blue eyes is consistent with the
theoretical value of $\frac{4p + 0.5}{6p + 4}\frac{p}{2} \approx$
0.0538.

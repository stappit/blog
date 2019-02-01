---
always_allow_html: True
author: Brian Callander
date: '2019-02-01'
output:
  md_document:
    preserve_yaml: True
    variant: markdown
tags: 'CISP chapter 2, casual inference, conditional independence, d-separation'
title: 'CIS Primer Question 2.4.1'
tldr: |
    Here are my solutions to question 2.4.1 of Causal Inference in
    Statistics a Primer (CISP).
---

Here are my solutions to question 2.4.1 of Causal Inference in
Statistics: a Primer (CISP).

<!--more-->
We'll use the following simulated dataset to verify our answers. The
coefficients are chosen so that each variable has approximately unit
variance.

``` {.r}
set.seed(29490)

N <- 10000 # sample size
sigma <- 1 # variance of nodes
e <- 0.1 # variance of errors

df <- tibble(
  id = 1:N,
  z1 = rnorm(N, 0, sigma),
  z2 = rnorm(N, 0, sigma),
  z3 = sqrt(1/2) * (z1 + z2) + rnorm(N, 0, e),
  x = sqrt(1/2) * (z1 + z3) + rnorm(N, 0, e),
  w = x + rnorm(N, 0, e),
  y = sqrt(1/3) * (w + z3 + z2) + rnorm(N, 0, e)
)
```

Part a
------

The nodes $\{W, Z_1\}$, $\{W, Z_2\}$, and $\{W, Z_3\}$ are each
d-separated by $X$.

The nodes $\{X, Y\}$ are d-separated by $\{W, Z_1, Z_3\}$.

The nodes $\{X, Z_2\}$ are d-separated by $\{Z_1, Z_3\}$.

The nodes $\{Y, Z_1\}$ are d-separated by $\{W, Z_2, Z_3\}$.

The nodes $\{Z_1, Z_2\}$ are d-separated by $\emptyset$.

In the above statements, the former nodes are all conditionally
independent given the d-separating set. In particular, the only two
variables that are unconditionally independent are $Z_1$, $Z_2$.

``` {.r}
part_a <- list(
    w_z1 = formula(w ~ 1 + z1 + x),
    w_z2 = formula(w ~ 1 + z2 + x),
    w_z3 = formula(w ~ 1 + z3 + x),
    x_y = formula(x ~ 1 + y + w + z1 + z3),
    x_z2 = formula(x ~ 1 + z2 + z1 + z3),
    y_z1 = formula(y ~ 1 + z1 + w + z2 + z3),
    z1_z2 = formula(z1 ~ 1 + z2)
  ) %>% 
  map(lm, df) %>% 
  map_dfr(broom::tidy, .id = 'model') %>% 
  separate(model, c('source', 'target'), '_', remove = FALSE) %>% 
  filter(source == term | target == term) %>%
  transmute(
    model,
    source,
    target,
    term,
    lower = estimate - 2 * std.error, 
    estimate,
    upper = estimate + 2 * std.error
  ) 
```

![Part a: the dependence of each pair conditional on the given
d-separation
set](question_2_4_1_files/figure-markdown/part_a_plot-1.svg)

Part b
------

The only conditioning sets used in part a that involve $Z_2$ were for
separating $\{Y, Z_1\}$. It's doesn't appear to me possible to find a
d-separating set that doesn't contain $Z_2$. For example, the only way
to block the chain $Z_1 \rightarrow Z_3 \rightarrow Y$ is to condition
on $Z_3$, which in turn unblocks the path
$Z_1 \rightarrow Z_3 \leftarrow Z_2 \rightarrow Y$, which can only be
blocked by conditioning on $Z_2$.

Part c
------

Two nodes are independent conditional on all other nodes if and only if
there is a path between them consisting purely of colliders.

Conditional on all other nodes:

-   $\{W, Z_1\}$ are independent
-   $\{W, Z_2\}$ are not independent
-   $\{W, Z_3\}$ are not independent
-   $\{X, Y\}$ are independent
-   $\{X, Z_2\}$ are independent
-   $\{Y, Z_1\}$ are independent
-   $\{Z_1, Z_2\}$ are not independent

``` {.r}
part_b <- list(
    w = formula(w ~ 0 + x + y + z1 + z2 + z3),
    x = formula(x ~ 0 + w + y + z1 + z2 + z3),
    y = formula(y ~ 0 + w + x + z1 + z2 + z3),
    z1 = formula(z1 ~ 0 + w + x + y + z2 + z3),
    z2 = formula(z2 ~ 0 + w + x + y + z1 + z3),
    z3 = formula(z3 ~ 0 + w + x + y + z1 + z2)
  ) %>% 
  map(lm, df) %>% 
  map_dfr(broom::tidy, .id = 'response') %>% 
  # filter(term != '(Intercept)') %>%
  transmute(
    response,
    term,
    lower = estimate - 2 * std.error, 
    estimate,
    upper = estimate + 2 * std.error
  ) 
```

![Part b: each variable regressed on all
others](question_2_4_1_files/figure-markdown/part_b_plot-1.svg)

Part d
------

No node can be independent of its parents or children, so the minimal
set for each node must include its parents and children. The minimal
sets that render each variable independent of all other variables are:

-   $W$: $\{X, Y\}$
-   $X$: $\{W, Z_1, Z_3 \}$
-   $Y$: $\{W, Z_2, Z_3 \}$
-   $Z_1$: $\{ X, Z_2, Z_3 \}$
-   $Z_2$: $\{ W, Y, Z_1, Z_3\}$
-   $Z_3$: $\{ W, X, Y, Z_1, Z_3 \}$

Part e
------

I originally thought that measuring just the two root nodes, $Z_1$ and
$Z_2$ would be sufficient since every other node is a function of those
two. However, comparing models via ANOVA suggests otherwise.

``` {.r}
e0 <- lm(y ~ z1 + z2, data = df) 
e_full <- lm(y ~ w + x + z1 + z2 + z3, data = df) 

anova(e0, e_full)
```

    Analysis of Variance Table

    Model 1: y ~ z1 + z2
    Model 2: y ~ w + x + z1 + z2 + z3
      Res.Df    RSS Df Sum of Sq      F    Pr(>F)    
    1   9997 263.24                                  
    2   9994 101.40  3    161.84 5317.2 < 2.2e-16 ***
    ---
    Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1

Since $Y$ is a direct function of $W, Z_2, Z_3$, restricting ourselves
to those three measurements would certainly be just as good. ANOVA
agrees with us on that one.

``` {.r}
e1 <- lm(y ~ w + z2 + z3, data = df) 

anova(e1, e_full)
```

    Analysis of Variance Table

    Model 1: y ~ w + z2 + z3
    Model 2: y ~ w + x + z1 + z2 + z3
      Res.Df    RSS Df Sum of Sq      F Pr(>F)
    1   9996 101.41                           
    2   9994 101.40  2  0.012199 0.6012 0.5482

Indeed, the coefficients for the remaining variables are not
statistically significantly different from 0.

``` {.r}
summary(e1)
```


    Call:
    lm(formula = y ~ w + z2 + z3, data = df)

    Residuals:
         Min       1Q   Median       3Q      Max 
    -0.40148 -0.06922 -0.00039  0.06870  0.35607 

    Coefficients:
                  Estimate Std. Error t value Pr(>|t|)    
    (Intercept) -0.0007178  0.0010075  -0.712    0.476    
    w            0.5793390  0.0058715  98.670   <2e-16 ***
    z2           0.5796524  0.0043199 134.182   <2e-16 ***
    z3           0.5728814  0.0100160  57.196   <2e-16 ***
    ---
    Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1

    Residual standard error: 0.1007 on 9996 degrees of freedom
    Multiple R-squared:  0.9965,    Adjusted R-squared:  0.9965 
    F-statistic: 9.364e+05 on 3 and 9996 DF,  p-value: < 2.2e-16

I'm not sure how to prove that this set of three measurments is minimal
though.

Part f
------

Although $Z_2$ has no direct causes, it does have direct effects on
$Z_3$ and $Y$.

``` {.r}
f_full <- lm(z2 ~ w + x + y + z1 + z3, data = df)
f0 <- lm(z2 ~ y + z3, data = df)

anova(f0, f_full)
```

    Analysis of Variance Table

    Model 1: z2 ~ y + z3
    Model 2: z2 ~ w + x + y + z1 + z3
      Res.Df     RSS Df Sum of Sq     F    Pr(>F)    
    1   9997 2784.93                                 
    2   9994  118.92  3      2666 74681 < 2.2e-16 ***
    ---
    Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1

However, the above comparison suggests that conditioning on just those
direct effects is not as good as conditioning on everything. This is due
to the fact that $Z_3$ and $Y$ are colliders, which open up information
flow between $Z_2$ and $W$, $Z_1$. Adding those two to the conditioning
set opens up no new paths to $Z_2$, so we are finished.

``` {.r}
f1 <- lm(z2 ~ y + z1 + z3, data = df)
f2 <- lm(z2 ~ w + y + z1 + z3, data = df)

anova(f0, f1, f2, f_full)
```

    Analysis of Variance Table

    Model 1: z2 ~ y + z3
    Model 2: z2 ~ y + z1 + z3
    Model 3: z2 ~ w + y + z1 + z3
    Model 4: z2 ~ w + x + y + z1 + z3
      Res.Df     RSS Df Sum of Sq         F Pr(>F)    
    1   9997 2784.93                                  
    2   9996  140.02  1   2644.92 222271.83 <2e-16 ***
    3   9995  118.92  1     21.09   1772.51 <2e-16 ***
    4   9994  118.92  1      0.00      0.05  0.823    
    ---
    Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1

The ANOVA agrees.

Part g
------

First of all, the model comparison suggests that the prediction quality
does improve if we add $W$.

``` {.r}
g0 <- lm(z2 ~ z3, data = df)
g1 <- lm(z2 ~ z3 + w, data = df)

anova(g0, g1)
```

    Analysis of Variance Table

    Model 1: z2 ~ z3
    Model 2: z2 ~ z3 + w
      Res.Df    RSS Df Sum of Sq     F    Pr(>F)    
    1   9998 4956.5                                 
    2   9997  543.6  1    4412.9 81149 < 2.2e-16 ***
    ---
    Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1

This is because conditioning on the collider $Z_3$ opens up the path

$$
Z_2
\rightarrow
Z_3
\rightarrow
Z_1
\rightarrow
X
\rightarrow
W
$$

which associates $Z_2$ and $W$.

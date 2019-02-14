---
always_allow_html: True
author: Brian Callander
date: '2019-02-14'
output:
  md_document:
    preserve_yaml: True
    variant: markdown
tags: 'CISP chapter 3, solutions, backdoor criteria'
title: 'CIS Primer Question 3.3.1'
tldr: |
    Here are my solutions to question 3.3.1 of Causal Inference in
    Statistics a Primer (CISP).
---

Here are my solutions to question 3.3.1 of Causal Inference in
Statistics: a Primer (CISP).

<!--more-->

Part a and b
------------

For the causal effect of $X$ on $Y$, every backdoor path must pass via
$Z$. Since $Z$ is adjacent to $X$, we must condition on $Z$. Since $Z$
is a collider for $B \rightarrow Z \rightarrow C$, we must also
condition on either $A$, $B$, $C$, or $D$. Thus, the sets of variables
that satisfy the backdoor criteria are arbitrary unions of the following
minimal sets:

-   $\{ Z, A \}$,
-   $\{ Z, B \}$,
-   $\{ Z, C \}$, and
-   $\{ Z, D \}$.

Part c
------

All backdoor paths from $D$ to $Y$ must pass both $C$ and $Z$. We can
block all backdoor paths by conditioning on $C$. If we don't condition
on $C$, then we must condition on $Z$. Since $Z$ is a collider,
conditioning on it requires us to also condition on one of $B$, $A$,
$X$, or $W$ (the nodes on the only backdoor path). The minimal sets
satisfying the backdoor criteria are:

-   $\{ C \}$,
-   $\{ Z, B \}$,
-   $\{ Z, A \}$,
-   $\{ Z, X \}$, and
-   $\{ Z, W \}$.

Note that $\{C, Z\}$ also satisfies the backdoor criteria but is not a
union of any minimal sets.

All backdoor paths from $\{D, W\}$ to $Y$ must pass $Z$ and must pass
either $C$ or $X$. The node $Z$ is sufficient to block all backdoor
paths after intervening on $D$ and $W$. If we don't condition on $Z$,
then we must condition on $X$ and $C$. The minimal sets satisfying the
backdoor criteria are:

-   $\{ C, X \}$, and
-   $\{ Z \}$ .

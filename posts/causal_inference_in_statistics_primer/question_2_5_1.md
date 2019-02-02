---
title: "CIS Primer Question 2.5.1"
author: "Brian Callander"
date: "2019-02-02"
tags: CISP chapter 2, casual inference, observational equivalence, unsolved
tldr: Here are my solutions to question 2.5.1 of Causal Inference in Statistics a Primer (CISP).
always_allow_html: yes
output: 
  md_document:
    variant: markdown
    preserve_yaml: yes
---

Here are my solutions to question 2.5.1 of Causal Inference in Statistics: a Primer (CISP).

<!--more-->

We'll use the following simulated dataset to verify our answers. The coefficients are chosen so that each variable has approximately unit variance.

## Part a and b

The book is not so clear on the definition of equivalent causal DAGs, and there are no explicit examples as far as I can tell. I'll assume the following definition:

Causal homomorphism
: Let $G$, $H$ be causal DAGs with skeletons $G_s$, $H_s$, respectively, and let $f : G_s \to H_s$ be a [graph homomorphism](https://en.wikipedia.org/wiki/Graph_homomorphism). Then $f$ is said to be a causal homomorphism if each collider in $G$ is mapped to a collider in $H$; that is, if $(x, z, y)$ is a collider in $G$, then $(f(x), f(z), f(y))$ is a collider in $H$. Moreover, $f$ is a causal isomorphism if it is bijective with an inverse that is also a causal homomorphism.

One implication of this is that the degree of any node is invariant under a causal isomorphism. In particular, $f(Z_3) = Z_3$, since $Z_3$ is the only node of degree 4. Furthermore, $f(X) \in \{ X, Y\}$, so $f(W) = W$. Thus, the only non-trivial causal isomorphism maps $f(X) = Y$, $f(Z_1) = Z_2$. In other words, the following causal DAG is the only causal DAG that is equivalent to figure 2.9 with different causal implications.

![The only DAG causally equivalent to figure 2.9](tikz/question_2_5_1_a_equivalent.svg){width=90%}

The above graph is the only one that is observationally equivalent to figure 2.9

## Part c

The directionality between $\{X, W\}$ and between $\{W, Y\}$ cannot be determined from nonexperimental data. 

## Part d


From part a of the [previous question](./question_2_4_1.html), we know that $\{W, Z_1, Z_3\}$ d-separates $\{Y, X\}$. This implies that the causal model from figure 2.9 is wrong is the coefficient of $X$ in the regression $Y \sim 1 + X + W + Z_1 + Z_3$ can be shown to be non-zero.

## Part e

Again from part a of the [previous question](./question_2_4_1.html), we know that $X$ d-separates $\{Z_3, W\}$. This implies that the causal model from figure 2.9 is wrong is the coefficient of $W$ in the regression $Z_3 \sim 1 + X + W$ can be shown to be non-zero.


## Part f

The only non-adjacent node to $Z_3$ is $W$. There is only one unblocked path between $Z_3$ and $W$: $Z_3 \rightarrow X \rightarrow W$. The only way to block this path is by conditioning on $X$, which wouldn't be possible if $X$ were unobservable. Therefore, it seems like it's not possible to find an equation that proves figure 2.9 wrong via a non-zero coefficient in a regression model of $Z_3$ with $X$ unobserved.

## Part g

The causal DAG tells us we can decompose the joint probability as:

$$
\mathbb P(W, X, Y, Z_1, Z_2, Z_3)
=
\\
\mathbb P (Z_1)
\cdot
\mathbb P (Z_2)
\cdot
\mathbb P (Z_3 \mid Z_1, Z_2)
\cdot
\mathbb P (X \mid Z_1, Z_3)
\cdot
\mathbb P (W \mid X)
\cdot
\mathbb P (Y \mid W, Z_2, Z_3)
.
$$

I'm unsure of the connection between this decomposition and implied vanishing partial regression coefficients. The 7 d-separation statements from [2.4.1 part a](./question_2_4_1.html) seem like they would be sufficient to fully test the model in this way.

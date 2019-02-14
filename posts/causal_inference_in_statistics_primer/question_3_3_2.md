---
always_allow_html: True
author: Brian Callander
date: '2019-02-14'
output:
  md_document:
    preserve_yaml: True
    variant: markdown
tags: CISP chapter 3, solutions, lord's paradox, simpson's paradox
title: 'CIS Primer Question 3.3.2'
tldr: |
    Here are my solutions to question 3.3.2 of Causal Inference in
    Statistics a Primer (CISP).
---

Here are my solutions to question 3.3.2 of Causal Inference in
Statistics: a Primer (CISP).

<!--more-->
Part a
------

The following DAG is a possible casual graph representing the situation.
We wish to find the causal effect of the plan on weight gain. The weight
gain $W_g$ is defined as a linear function of the initial and final
weights. From the graph we see that the plan chosen by the students is a
function of their initial weight.

![A casual diagram for Lord's paradox](tikz/question_3_3_2.svg){width=70%}

Part b
------

Since initial weight $W_I$ is a confounder of plan and weight gain, the
second statistician is correct to condition on initial weight.

Part c
------

The causal diagram here is essentially the same as in Simpson's paradox.
The debate is essentially the direction of the arrow between initial
weight and plan.

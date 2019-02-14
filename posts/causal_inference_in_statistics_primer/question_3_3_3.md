---
always_allow_html: True
author: Brian Callander
date: '2019-02-14'
output:
  md_document:
    preserve_yaml: True
    variant: markdown
tags: 'CISP chapter 3, solutions, backdoor criteria'
title: 'CIS Primer Question 3.3.3'
tldr: |
    Here are my solutions to question 3.3.3 of Causal Inference in
    Statistics a Primer (CISP).
---

Here are my solutions to question 3.3.3 of Causal Inference in
Statistics: a Primer (CISP). $\DeclareMathOperator{\do}{do}$

<!--more-->


The drug you have been assigned determines which ward you go to. Whether you get a lollipop is determined by which ward you go to and whether you show signs of depression. Depression is a symptom of certain risk factors. These risk factors, together with the drug you have been assigned, determine your capacity for recovery.

![A causal model for the lollipop situation.](tikz/question_3_3_3.svg){width=70%}

Since `lollipop` is a collider in this diagram, there are no backdoor paths from `drug` to `recovery`. In other words, it is not necessary to condition on any variables to estimate the causal effect of `drug` on `recovery`.  In this case, $\mathbb P (Y \mid \do(X)) = \mathbb P(Y \mid X)$.

If the nurse were to give out the lollipops in the day after the study, there would be no difference in the causal diagram. 


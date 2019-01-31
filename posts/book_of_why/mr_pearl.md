---
title: P is for Pearl
author: "Brian Callander"
date: "2019-02-01"
tags: judea pearl, andrew gelman, mrp, causality, selection bias, confounders, surveys
tldr: We take a look at Gelman's MRP framework from the perspective of Pearl's causal diagrams in the presence of selection bias. To give this some context, we consider the variables in Gelman & Co's 2014 Xbox Live paper.
always_allow_html: yes
output: 
  md_document:
    variant: markdown
    preserve_yaml: yes
---

Andrew Gelman and collaborators developed methodology called MRP to correct for sampling bias in election polls. One dramatic example of this is in their awesome [2014 paper](https://www.microsoft.com/en-us/research/wp-content/uploads/2016/04/forecasting-with-nonrepresentative-polls.pdf), where they conduct an Xbox Live survey on voting intentions and show that MRP is powerful enough to correct such non-representative sampling to obtain estimates comparible to standard prediction markets.  Unrelatedly, in the same year Judea Pearl and collaborators [published a paper](https://www.aaai.org/ocs/index.php/AAAI/AAAI14/paper/viewFile/8628/8707) showing that their backdoor adjustment can be extended to the case of sampling bias. I'm loving the whole [back-and-forth between the two camps](https://statmodeling.stat.columbia.edu/2012/07/16/long-discussion-about-causal-inference-and-the-use-of-hierarchical-models-to-bridge-between-different-inferential-settings/), so I thought it'd be a fun exercise to cast MRP as a causal diagram. In the [words of one of the commenters](https://statmodeling.stat.columbia.edu/2019/01/08/book-pearl-mackenzie/#comment-943010):

> Awesome! A superhero versus superhero movie. I’m gonna hit Pause and go make popcorn. BRB.

<!--more-->

I'm a newbie to causal theory, so bear with me.

<div style="display:none">
  $\DeclareMathOperator{\do}{do}$
</div>



## MRP

Gelman [first published](http://www.stat.columbia.edu/~gelman/research/published/poststrat3.pdf) MRP in 1997 as a powerful method to adjust for sampling bias in US election polling. It constists of two parts:

1. Multilevel Regression (= hierarchical regression), where the response is modelled conditional on the relevant demographic cells; and

2. Poststratification, a framework for weighting the conditional probabilities by their relative proportion in the general population, where the weights can be obtained from census data.

The intuition is that if your demographic cells are fine enough, then the data in each of the cells are just like simple randomly sampled data. The hierarchical nature of the regression allows you to make cells that are sufficiently fine without overfitting. It has apparently [found](https://yougov.co.uk/topics/politics/articles-reports/2017/05/31/how-yougov-model-2017-general-election-works) [many](http://www.misterp.org/papers.html) [applications](http://www.stat.columbia.edu/~gelman/research/published/swingers.pdf) in political science.

## Selection-backdoor adjustment

If you are unfamiliar with Pearl's causal diagrams, the [primer](http://bayes.cs.ucla.edu/PRIMER/) is a great technical introduction and the [book of why](https://books.google.de/books?id=BzM0DwAAQBAJ&printsec=frontcover&dq=The+Book+of+Why:+The+New+Science+of+Cause+and+Effect#v=onepage&q=The%20Book%20of%20Why%3A%20The%20New%20Science%20of%20Cause%20and%20Effect&f=false) is a good read framing them in the context of Pearl's general philosophy. One item discussed in those books is the backdoor adjustment, which tells us how to estimate causal effects in the presence of confounding variables.

Pearl & Co more recently [published](https://pdfs.semanticscholar.org/b8a3/067d6c1fb255c9cdb5ac66037b82152ab3bb.pdf)  [some](https://www.aaai.org/ocs/index.php/AAAI/AAAI14/paper/viewFile/8628/8707) [papers](https://www.cs.purdue.edu/homes/eb/r29.pdf) related to selection bias. In particular, they introduce the selection-backdoor adjustment, which tells us how to estimate probabilistic and causal effects in the presence of selection bias. In the section below, we'll simply state and apply the results without justification; see [Theorem 2, Definition 4 (selection-backdoor criteria), and Theorem 5 (selection-backdoor adjustment)](https://www.aaai.org/ocs/index.php/AAAI/AAAI14/paper/viewFile/8628/8707) for the full details.

## MR. Pearl

The Xbox Live paper illustrates MRP well since the poll is clearly heavily biased towards younger men. In Pearl's language, we could say $Z := \{\text{sex}, \text{age} \}$ are direct causes of both $S := \text{selection}$ and $Y := \text{voting intention}$. Gelman also identifies a number of other features relevant to voting intention, which we'll denote by $X$: `race`, `education`, `state`, `party ID`, `ideology`, and `2008 vote`. These other features are not indicated in the paper as causes of `selection`, and the plots shown don't strongly suggest they are either. We'll ignore possible causal interactions between the political and historical features and work with the following simplified causal model:

![A possible causal diagram for the Xbox paper](tikz/xbox.svg){width=70%}

where `selection` is highlighted because the collected data is implicitly conditioned on `selection = 1`. This conditioning is important because $Z$  are confounders for $S$ and $Y$. 

Suppose we want to estimate the causal effect of $X$ on $Y$. Conditioning on $Z$ blocks all paths between $S$ and $Y$, rendering the response independent of selection, and we have population-level data on $Z$. In other words, $Z$ satisfies the selection-backdoor criteria with respect to $X$ and $Y$. Thus, we can apply the selection-backdoor adjustment, which is given by:

$$
\begin{align}
  \mathbb P (Y \mid \do(X = x))
  &=
  \sum_{z} 
  \mathbb P (Y \mid Z = z, X = x, S = 1) 
  \cdot
  \mathbb P (Z = z)
\end{align}
$$

The first factor on the right hand side is simply the response probability conditional on the relevant demographic features, as estimated from the data. This can be estimated by Multilevel Regression, for example. The second factor is the probability of the demographic cells, which we can estimate from external census data. Thus, the sum is precisely Poststratification of the Multilevel Regression estimates: MRP!

Interestingly, the causal effect is different from the (non-causal) conditional probability, which Pearl & Co tell us is

$$
\begin{align}
  \mathbb P (Y \mid X = x)
  &=
  \sum_{Z = z} 
  \mathbb P (Y \mid Z = z, X = x, S = 1) 
  \cdot
  \mathbb P (Z = z \mid X = x)
\end{align}
$$

where the second factor on the right hand size is now conditional on $X$. With this probability, we can apply the [law of total probability](https://en.wikipedia.org/wiki/Law_of_total_probability) to calculate the unconditinoal probability of voting intention as

$$
\begin{align}
  \mathbb P (Y)
  &=
  \sum_X \mathbb P(Y \mid X) \mathbb P (X)
  \\
  &=
  \sum_X
  \sum_Z 
  \mathbb P (Y \mid Z, X, S = 1) 
  \cdot
  \mathbb P (Z \mid X)
  \cdot
  \mathbb P (X)
  \\
  &=
  \sum_{X, Z}
  \mathbb P (Y \mid Z, X, S = 1) 
  \cdot
  \mathbb P(Z, X)
\end{align}
$$

which is again the MRP estimate!

## Further resources

* [Pearl, Glymour, Jewell: Causal inference in Statistics, a primer](http://bayes.cs.ucla.edu/PRIMER/), an introduction to causal diagrams, including the backdoor adjustment
* [Bareinboim, Tial, Pearl: Recovering from Selection Bias in Causal and Statistical Inference](https://www.aaai.org/ocs/index.php/AAAI/AAAI14/paper/viewFile/8628/8707), an extension of the backdoor adjustment that works in the presence of selection bias
* [Kastellec: MRP primer](https://www.princeton.edu/~jkastell/mrp_primer.html), a MRP tutorial using [lme4](https://www.rdocumentation.org/packages/lme4/versions/1.1-19)
* [Rochford: MRPyMC3](https://austinrochford.com/posts/2017-07-09-mrpymc3.html), a MRP tutorial using [PyMC3](https://docs.pymc.io/)
* [Mastny: MRP Using brms and tidybayes](https://timmastny.rbind.io/blog/multilevel-mrp-tidybayes-brms-stan/), a MRP tutorial using [brms](https://github.com/paul-buerkner/brms)

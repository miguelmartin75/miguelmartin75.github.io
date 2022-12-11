---
title: Initialization schemes
tags: ml
---

Hypothesis: some conditions should be true for a randomly initialized network to learn effectively:

1. Initialization => should be unbiased w.r.t data used
   a. Either pick a better initialization scheme, or
   b. Perform semi-supervised learning technique to minimize entropy ( #todo cite here) - http://www.iro.umontreal.ca/~lisa/pointeurs/semi-supervised-entropy-nips2004.pdf
2. A randomly initialized architecture should map each input to a "different mapping" for each input - as it is unbiased


# [[Rethinking the value of network pruning]]

Xavier http://proceedings.mlr.press/v9/glorot10a/glorot10a.pdf

Learning Discrete Representations via Information Maximizing Self-Augmented Training
https://arxiv.org/pdf/1702.08720.pdf


- Weight Agnostic Neural Networks https://arxiv.org/pdf/1906.04358.pdf
  + Some-what of a contradiction to the [[a]]
  + Well not quite but it is close


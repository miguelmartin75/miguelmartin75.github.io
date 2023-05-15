---
title: Rethinking the value of network pruning
source: https://arxiv.org/abs/1810.05270
tags: paper ml
state: draft
---

# Summary
- States LTH's method of finding a winning ticket is not necessary
- It's commonly believed in literature that you have to: train, then prune and then fine-tune
- But this is not necessary for unstructured pruning
- Instead, you can find a better set of hparams for the optimization method, e.g. for SGD
- For unstructured pruning this does not scale to ImageNet. They do not know why. Only comparable perf for smaller datasets (and models?)

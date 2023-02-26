---
title: Model Understanding
tags: ml
state: draft
---


# Model Understanding #todo 

- in an ideal world we would understand problem
  - even in "ideal" world - probably not possible for some tasks due to complexity of problems
- or be able to guarantee that the model is correct every time => in that case we would effectively need trust

- This is only issue for models that are non-interpretable (e.g. not a decision tree or linear model)
- main use case is model debugging
- Heart of machine learning is the data

# Approaches to the problem

## Visualization
- "seeing is believing" - visualizing the internals of a system is useful for understanding and learning
## Interpretability and Explainability
- What features did the model pay attention to when making a prediction?
## Robustness
- Are there spurious correlations/learnt features?
- i.e. did the model learn the problem using the same of features we use to solve it?
## Dataset
- Are there subsets of the data that are interesting
## Architecture
- Attention-based networks - TODO: link papers here contradicting the meta-analysis
### Analysis
- Which weights are redundant?
### Search
- Can I design a network and/or the structure of the problem being solved to be more interpretable?
## What a neural network does
- Extraction of rules
- Feature


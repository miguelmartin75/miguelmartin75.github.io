---
title: Self-Attention
state: draft
---

Sequence to sequence operation

For each output $y_i$: weighted sum of inputs ($x_j$), where weight is a function between corresponding input $x_i$ and $x_j$, i.e.

$\text{SA}(x_i) = y_i = \sum_{j}{ f(x_i, x_j) x_j }$

Unlike fully connected network due to the fact that the *weights* are dependent on the *inputs*

* Attention Heads
Stacking attention. This is due to the fact that order does not matter. Thus, adding attention heads can encode ordering.

Alternatively, one could encode the position of the sequence in the input.

* Common Weight Functions
- Dot Product
- Dot Product with softmax to map to [0, 1]

# Related

- TODO link Non-Local Networks

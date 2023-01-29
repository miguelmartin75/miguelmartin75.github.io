---
title: An Approximation Algorithm for Optimal Subarchitecture Extraction
source: https://arxiv.org/abs/2010.08512
tags: paper ml
---
# Summary #todo

# Problem
## Optimal Sub-architecture Extraction
Select the best non-trainable parameters for a NN such that it is optimal w.r.t parametrize size, inference speed and error rate.

Class of networks that satisfy the following three conditions:
1. Intermediate layers are more expensive in terms of param size and number of ops than I/O functions
2. Optimization problem is L-Lipchitz smooth with bounded stochastic gradients
3. Training procedure uses SGD

Above assumptions are labelled as the $\text{AB}^nC$ property

Assumption: optimization problem is u-strongly convex then the algorithm is a FPTAS with approximation ratio of $p \leq | {1 - \epsilon} |$

---

Can be seen as an Architecture Search Problem, where the architecture remains fixed but the non-trainable parameters do not.

# OSE

"Optimal Sub-architecture Extraction"

- Find set of non-trainable params for deep NN $\mathbb{R}^p \to \mathbb{R}^q$
- layer is a non-linear function: $l_i(x, W_i)$ takes input $x \in \mathbb{R}^p_i$ and a finite set of trainable weights, $W_i = \{w_{i,1}, ... w_{i,k}\}$; every $w_{i,j} \in W_{i}$ is an r-dimensional array (vector)
- Supervised dataset $D = {(x_i, y_i)}_{i=1,...,m}$, unknown probability distribution. Search space is $S$ (Ξ in the paper).
- Set of possible weak assignments $W$, set of hyper-parameter combinations $\theta$ and architecture $f(x) = l_n(l_{n-1}(...l_1(x;W;\xi_1)...; W_{n-1}; \xi_{n-1}), W_{n}, \xi_{n})$

## Surrogates the objective values
### Inference Speed
Sum of for each layer i:
- Number of additions
- Number of multiplications
- Number of other operations in layer i

# Related Work
- NAS
- Weight Pruning
- General neural network compression techniques
# Complexity
- Behaves like an FPTAS
- Runs in $O(|E| + |W_T^{*}(1 + |B| |E|) / \epsilon s^{3/2})$

# Search Space

FPTAS search algorithm

Hparams it searches over:
- Attention heads (A)
- Encoder layers (D)
- Hidden size (H)
- Intermediate layer size (I)

BERT-base has D=12, A=12, H=768, I=3072

They search over:
| Name                      | Variable | Values | Description |
|:--------------------------|:---------|:--------|:-------|
| Number of Attention Heads | A | {4, 8, 12, 16}              |                         |
| Number of Encoder Layers  | D | {2, 4, 6, 8, 10, 12}        |                         |
| Hidden Size               | H | {512, 768, 1024}            | H must be divisble by A |
| Intermediate Layer Size   | I | {256, 512, 768, 1024, 3072} |                         |

Ignoring configurations where H is not divisible by A

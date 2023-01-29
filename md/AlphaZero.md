---
title: AlphaZero
tags: ml, study, notes
---

<https://tmoer.github.io/AlphaZero/>
<https://web.stanford.edu/~surag/posts/alphazero.html>

-   s = state of the board
-   $f_\theta(s)$ neural net, two outputs
    -   continuous value of the board state
    -   policy $p_\theta(s)$, probably vector over all possible actions

Training examples are in the form of: (s~t~, pi~t~, z~t~)

-   $\pi_t$ is estimate of policy from state s~t~
-   $z_t = \{1, -1\}$ is the final outcome of the game from perspective
    of player at $s_t$ (-1 for lose, +1 for win)

# Loss #todo 

$$\sum (v_{\theta}(s_t) - z_t)^2 - \vec{pi}_t * \log(\vec{p_\theta}(s_t))$$

Terms:

This is excluding regularization terms.

# MCTS Search for Policy Improvement #todo 

-   Given state s, we get the policy $\vec{p}_\theta$
-   During training, estimate of the policy is improved via Monte Carlo
    Tree Search

During the tree search the following is maintained:

-   $Q(s, a)$: the expected reward for taking action $a$, from state $s$
-   $N(s, a)$: the number of times action $a$ was taking from state $s$
    across simulations
-   $P(s, \cdot) = \vec{p}_\theta(s)$: the initial estimate of taking
    action from state $s$ according to policy returned by the current
    network

Compute $U(s, a)$, the upper confidence bound on Q-values as:

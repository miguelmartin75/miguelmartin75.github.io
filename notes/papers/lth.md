TODO: title

- Pruning can reduce network by 90% without compromising accuracy
- Standard pruning naturally uncovers sub-networks whose initialization made them capable of training effectively
- They find "winning tickets" consistently for MNSIT and CIFAR10

Formally:

- $$f(x, \theta)$$ is some dense FF network where $$\theta_0 \sim D_\theta$$ for some distribution of parameters $$D_\theta$$
- $$f$$ reaches $$l$$ validation loss and test accuracy $$a$$ at some iteration $$j$$ from e.g. SGD
- Consider training $$f(x, m \odot \theta)$$ for some fixed mask $$m \in \{0, 1\}^{\norm{\theta}}$$
  + This will reach some validation loss $l'$, at iteration $j'$ for some test accuracy $a'$
- LTH States: $$\exists M$$ where $j' \leq j$, $a' \leq a$


To find such $M$ they propose an algorithm:

1. Randomly initialize $f(x, \theta_0)$
2. Train for some fixed iterations
3. Prune p% of the network, to construct the mask $M$
4. Reset the parameters to $\theta_0$ and retrain the model

Repeat this procedure iteratively over n rounds, combining the mask over each round. They should empirically that this out-performs doing this once.

They have experimental results on MNIST and CIFAR10


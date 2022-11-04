---
slug: "/blog/neural-archs"
date: "2022-07-01"
title: "Understanding Transformers (from Scratch)"
---

# Notes

What is the focus here?
1. Understanding of attention?
2. Implementation?
3. Exploration?

If we go with WebGPU or whatever and implement it from "scratch" then we will
just be focused on the implementation... we could do a two part blog here to
compensate.

One annoyance would just be how do we test the performance on e.g. imagenet for
an "equivalent" fully connected network

---



If MLPs are universal approximators, why are transformers so much more
effective?

# Abstract 

Transformers are all the craze today and for a good reason. They've been shown
to be effective for all kinds of modalities (text [TODO], audio [TODO], visual [TODO]) and tasks
(TODO). But
what are they, how do they work, what's their pros/cons, and
what are the alternatives?

# Introduction

The goal of the article is to gain an understanding and intuition for
transformers and attention. We'll look at the alternatives and hopefully by the
end of this article, we will understand whether attention is really "all you
need" (TODO cite).

To do this we implement Transformers from scratch, visualized interactively in
the browser, using WebGPU's compute shaders. We will work our way to
Transformers from the very start (the Perceptron), move to convolutional neural
networks (CNNs), then to self-attention and then finally to the transformer.

TODO: I have additionally implemented the same code in PyTorch, which is available on
my Github here.

Once we're at the Transformer I will make an attempt to understand them and why
they are so much more effective than a plain MLP and CNNs. We will look at
alternatives such as ones proposed in "Watch out for MLPs". 

# Perceptron 

Perceptrons are quite simple networks, just a simple affine (linear) transformation. Defined as:

$$
f(x) = Ax + b
$$

Their gradient is also quite simple: TODO

Typically one applies a softmax to normalize the outputs to range from $[0, 1]$
such that they can be interpreted as probabilities.


## Multi-Layed Perceptrons (MLPs)

If add additional layers to the perceptron, with each layer following a
non-linear activation function, we will end up with the MLP. The non-linear
activation function is important, as if we just blindly add layers to the
percepton, we will just end up where we started: a perceptron. 

If we use ReLU, our resulting non-linear function will be equivalent to a
piece-wise linear function. This is a universal approximator.

That is, two affine transformations in sequence is equal
to one. Thus, we need to 


# CNNs (for vision)

Convolutional Neural Networks originate in 19XX (TODO) and were popularized from
AlexNet. AlexNet was revolutionary at the time, it showed that if you take
advantage of the compute you have, one can train a large network (relative at
the time) and achieve state of the art results on image classification
(ImageNet). From AlexNet it spurred a craze of CNN architectures, from VGG16, to
Microsoft's ResNet, to Google's InceptionNet.


# Deep Networks & Vanishing Gradients (Residual Connections)

Scaling AlexNet to many layers is hard. Before ResNet (TODO paper) the best (I
know) which was achieved was X layers from VGG.

To achieve this, ResNet came along and introduced the residual connection
(residual block). This allows you to scale your neural network to an arbitrary
number of layers without encountering "the vanishing gradient" problem.

# Initialization

Xavier: TODO

# Self-Attention

Self-attention, a.k.a. non-local transformations, contrary to a convolution,
allows modelling long range dependencies between inputs. 

When self-attention/non-local transformations were used/introduced? in non-local
neural networks (TODO cite), they were used after a convolution transformation. Allowing you
to model long-range dependencies in space, time or space-time for images &
videos.


# Transformers

```python
x + 1
```

Introduced independently from self-attention this is a generalization of self-attention.



# TODO

In future posts, we will cover ways to optimize their performance via sparsity,
half precision, etc.

---
slug: "/blog/collatz-conjecture-multiply"
date: "2022-08-06"
title: "How to Multiply with the 3n + 1 series (Collatz Conjecture)"
tags: math
state: publish
---

# Table of Contents

```toc

```

# Introduction

I stumbled across an [interesting paper](https://link.springer.com/article/10.1007/s00224-020-09986-5), which shows that you can multiply two numbers by using the Collatz conjecture (and assuming it to be true for the numbers you are dealing with).

This post contains my summary and understanding of how this method works.

# Background

## Collatz conjecture
### Definition
The [Collatz conjecture](https://en.wikipedia.org/wiki/Collatz_conjecture), also known as the $3n + 1$ problem, is a simple to describe, yet unsolved, problem in discrete mathematics. The conjecture states that if you start with a positive integer $n$ and apply the following rule to it:

- If the number ($n$) is even, divide it by two: $\frac{n}{2}$
- If the number ($n$) is odd, multiply it by 3 and add one: $3n + 1$

The number will eventually land in the cycle $4 \rightarrow 2 \rightarrow 1 \rightarrow 4$. The conjecture states: this the only cycle. There is no proof to confirm this, however, we have tested up to a very large number and the conjecture seems to hold. Thus, for all practical purposes: the conjecture is true.

The rule can be mathematically written as:

$$

f(n) = 
\begin{cases}
    \frac{n}{2} &\text{if } n \equiv 0 \text{ (mod 2)} \\
    3n + 1 &\text{otherwise}
\end{cases}

$$

### Examples

$10$
- $5$
- $16$
- $8$
- $4$
- $2$
- $1$ (cycle starts)


$18$
- $9$
- $28$
- $14$
- $7$
- $22$
- $11$
- $34$
- $17$
- $52$
- $26$
- $13$
- $40$
- $20$
- $10$ (use above)

# Method

## Definitions

### Collatz Function
Define the Collatz function, $F$, as the Collatz conjecture with path of dividing by 2 compressed into one step, that is:

Given $$x$$, a positive odd integer:

$$
    F(x) = \frac{3x + 1}{2^{\text{ctz}(3x + 1)}}
$$

- $$\text{ctz}(x)$$ gives the number of factors of 2 in a number, i.e. count the
  trailing zeros of a number in binary

### Collatz sequence and $k$

- The Collatz sequence, is the sequence of numbers produced by the Collatz
  function until it reaches the number $1$ for the first time
- Define $k$ as the number of steps until the Collatz series lands on $1$

In other words, the Collatz sequence can be shown mathematically like so:
$$
    x, F_1(x), F_2(x), ..., F_{k-1}(x), 1
$$

## How to Divide: $$\frac{m}{a}$$

Let's multiply the Collatz function series by $$a$$, we get:

$$
    ax, aF_1(x), aF_2(x), ..., aF_{k-1}(x), a
$$

Let $$m = ax$$, we get

$$
    \begin{aligned}
    a F(x) & = a \frac{3x + 1}{2^{\text{ctz}{(a(3x + 1))}}} \\
           & = \frac{3ax + a}{2^{\text{ctz}{(3ax + a)}}} \\
           & = \frac{3m + a}{2^{\text{ctz}{(3m + a)}}} \\
           & = G(m)
    \end{aligned}
$$

NOTES: $$ctz(3m+a) = ctz(3m+1)$$ when $$a$$ is odd


Assuming $a \mid m$ ($a$ divides $m$), we can:

1. Start with $m$
2. Use $G(m)$ until we get to $a$
    - Record what we've done to get there
    - i.e. save the result of $\text{ctz}(3x + 1)$ along the way and $k$
      (the number of steps)
4. Backtrack using the same form of operations (in reverse) with $F(x)$ whilst
   starting at $1$

i.e. we have a division algorithm using the Collatz conjecture

## How to Multiply: $ax$

Now, how do we multiply? Simple: 

- Start with $x$ and use $F(x)$ until we get to $$1$$
    - Record what we've done (save the $k$ steps)
- Now, start with $$a$$ and backtrack with $G(x)$ (with the saved $k$ steps),
  which will get us to $ax$

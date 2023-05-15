
---
title: Instant Neural Graphics Primitives with a Multiresolution Hash Encoding
source: https://nvlabs.github.io/instant-ngp/assets/mueller2022instant.pdf
code: https://github.com/NVlabs/instant-ngp
tags: ml paper
---

- neural graphics primitives are parametrized with MLPs, which are costly to train and eval
- this paper introduces new input encoding that allows a small network to learn, which reduces FLOPs and memory access ops significantly
- "multiresolution hash encoding" is what they they introduce, due to:
	- adaptivity TODO
	- efficiency as it is a hashmap, i.e. O(1) lookup, with a 1:1 correspondence with the input. No control flow (slow on GPUs)
- references kernel trick and one-hot encoding
- frequency encoding introduced by Vaswani et al. encode via (this is adopted by NeRFs):
	- encoding $x \in R$, using $L \in N$
	- $(sin(2^0x), sin(2^1 x), ..., sin(2^{L-1} x), cos(2^0 x), cos(2^1 x), ..., cos(2^{L-1} x))$
- parametric encodings: learn how to encode
- 
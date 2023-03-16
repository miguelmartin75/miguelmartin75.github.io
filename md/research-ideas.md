---
title: Research Ideas
---

## Generative model dataset (data distillation)
- use LLM as the data source, sampling the distribution of tokens
- I'm sure people have done this
- Is it possible to filter out biases or sentences/paragraphs that don't make sense or have significant biases we do not want to include in the model? 

## Video NeRF without estimated camera poses
Related: [[NeRFs]], [[Efficient Neural Radiance Fields for Interactive Free-viewpoint Video]]
- #todo https://arxiv.org/pdf/2102.07064.pdf

Problems to solve:
- dynamic content in scene
- no camera params
	- learn by applying affine transform over time, keeping focal length fixed


## Exploiting High Quality Datasets with low amounts of data
- Can we learn the language of formal logic?
- Can we learn writing formal algorithms?

##  Masked Embedding Loss
Related: [[loss-fns#MLM]]
- This might be mathematically equivalent to what is being done already. I'm not sure about this point though.
- Start with cross-entropy on the tokens then gradually migrate to L2 loss on the embeddings for the words

## NeRFs with Motion
- objects in scene under motion
- how do we model this?

## PL Designs / Features
### Machine Learning Applications in PL
- Translation from source -> IR or machine code
- Efficient data structure representations (can we do this with search?)
### JIT + REPL
Implementation:
- LLVM JIT?
	- Con: Need to use LLVM as the IR
- Linker design changes

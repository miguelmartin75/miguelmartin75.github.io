---
title: Research Ideas
---

# Exploiting High Quality Datasets
- Can we learn the language of formal logic?
- Can we learn writing formal algorithms?

#  Masked Embedding Loss
Related: [[loss-fns#MLM]]
- This might be mathematically equivalent to what is being done already. I'm not sure about this point though.
- Start with cross-entropy on the tokens then gradually migrate to L2 loss on the embeddings for the words

# NeRFs with Motion
- objects in scene under motion
- how do we model this?
# PL Designs / Features
## Machine Learning Applications in PL
- Translation from source -> IR or machine code
- Efficient data structure representations (can we do this with search?)
## JIT + REPL
Implementation:
- LLVM JIT?
	- Con: Need to use LLVM as the IR
- Linker design changes

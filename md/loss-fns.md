---
title: Interesting Loss Functions
---

# Triplet Loss #todo 

- positive example
- negative example
- anchor
	- has the same identity as anchor

High-level goal:
- influence anchor and positive example to be closer, and
- influence anchor and negative example to be further apart

e.g. use L2 distance or some other distance metric

Qs:
- Why not just sample 1 positive and 1 negative?


# MLM

Used for BERT/RoBERTa: https://arxiv.org/pdf/1907.11692.pdf

Instead of predicting the token - why not predict the embedding vector representing the missing token?

IDEA MLM Embedding Loss
This might be mathemtically equivalent to what is being done already. I'm not sure about this point though.

Basically start with cross-entropy on the tokens then gradually migrate to L2 loss on the embeddings for the words.



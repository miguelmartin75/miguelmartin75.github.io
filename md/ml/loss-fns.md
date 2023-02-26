---
title: Interesting Loss Functions
---

# Triplet Loss
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

Qs:
- Instead of predicting the token - why not predict the embedding vector representing the missing token?

MLM Embedding Loss #idea 

# Contrastive Losses
https://towardsdatascience.com/contrastive-learning-in-3-minutes-89d9a7db5a28
## InfoNCE #todo 
## SimCLR #todo 
## MoCo #todo 

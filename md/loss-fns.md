---
title: Interesting Loss Functions
---

# Triplet Loss #todo 

# MLM

Used for BERT/RoBERTa: https://arxiv.org/pdf/1907.11692.pdf

Instead of predicting the token - why not predict the embedding vector representing the missing token?

IDEA MLM Embedding Loss
This might be mathemtically equivalent to what is being done already. I'm not sure about this point though.

Basically start with cross-entropy on the tokens then gradually migrate to L2 loss on the embeddings for the words.



---
title: Decoder-Only Transformers are SoTA Encoders (with some fine-tuning)
date: 2025-05-20
state: publish
---

# tl;dr

* Despite their name, decoder-only Transformers (M-LLMs, e.g. Llama, Mistral,
  Qwen, etc.) **can be fine-tuned into an encoder to obtain embeddings** for
  retrieval tasks, e.g. RAG, semantic search, etc., which can achieve state-of-the-art (SoTA) results
* **You can have your cake and eat it too:** the same M-LLM fine-tuned for
  embeddings can be used to generate text without loss in performance. See
  [GRIT](https://arxiv.org/pdf/2402.09906) on how this can be done.

# Introduction

Decoder-only transformer architectures have taken over. Encoder-based
transformer (encoder-only, encode-decode) architectures (e.g.
[BERT](https://huggingface.co/docs/transformers/model_doc/bert)) are becoming
something of the past, the latest encoder-based transformer was released
~[2](https://huggingface.co/google/flan-ul2) years ago. Large research labs are
no longer training encoder-based models, and this is for a good reason:
encoder-based architectures are harder to scale.

No newly encoder-based transformers leave us with a problem: how should we
obtain state-of-the-art (SoTA) embeddings? Will individuals or smaller
labs/companies be forced to depend on proprietary models such as [Gemini
Embedding](https://developers.googleblog.com/en/gemini-embedding-text-model-now-available-gemini-api/),
[OpenAI embeddings](https://platform.openai.com/docs/guides/embeddings), or
[Voyage Code](https://blog.voyageai.com/2024/12/04/voyage-code-3/) (all are
likely decoder-only transformers)? Or continue using old encoder models, such
as [`all-mpnet-base-v2`](https://huggingface.co/sentence-transformers/all-mpnet-base-v2)?
Or, will we need to train new encoder-based models to keep up with the
continued advancements decoder-only models are achieving?

The answer to the above questions is in the title of this post: no, we don't
need encoder-based transformers. One can use an existing pre-trained
decoder-only transformer as a base for an encoder. Many people and companies are doing this
already, in fact, as I was writing this post, a new model by
ByteDance (the company behind TikTok) popped up on the MTEB leaderboard and
topped the leaderboard: [Seed-1.5-Embedding](https://huggingface.co/ByteDance-Seed/Doubao-1.5-Embedding)
which is based on their LLM (decoder-only transformer).

You might still wonder why bother? LLMs are typically large, and performing
a forward pass is not cheap. SBERT is computationally cheap to run as it can run
on a cheap VPS (CPU). My counter-arguments here are: 
1. You can have your cake and eat it too:
    * If you're hosting a generative LLM already, you could fine-tune your
      generative LLM to encode text without degrading generative performance.
      For RAG, you can use k-v caching to speed up the RAG pipeline.
    * See [GRIT](https://arxiv.org/pdf/2402.09906) for evidence that it is
      possible: "Notably, we find that GRIT matches training on only generative
      or embedding data, thus we can unify both at no performance loss".
    * To prevent generative performance regression, you essentially need to jointly train
      an embedding objective (contrastive loss, e.g. InfoNCE) with a generative
      objective (next-token prediction).
2. Smaller LLMs (<1B params) are continuing to get better due to advances in training data,
   training recipes/techniques, e.g. distillation. [Qwen3 0.6B](https://qwenlm.github.io/blog/qwen3/) can run on mobile
   devices, and qualitatively it performs well (I can't find benchmark numbers for this variant of Qwen3).

# Background
Feel free to [skip](#how-can-you-make-a-decoder-an-encoder) this section if you're familiar with embeddings/vector-based search.

Encoders have the nice property of being able to take some input data (e.g.
text, images, audio, etc.) and spit out an embedding vector associated to this.
This embedding vector can then be used to solve various tasks efficiently, such as
retrieval, clustering, pair classification. Commonly embeddings vectors are
used for semantic search, [Retrieval Augmented Generation
(RAG)](https://en.wikipedia.org/wiki/Retrieval-augmented_generation) and
recommendation. 

We can use embedding vectors for these tasks because the space these vectors
occupy is a [Metric space](https://en.wikipedia.org/wiki/Metric_space) defined
by some function $f(x_1, x_2)$. Meaning one can perform a nearest neighbour search (k-NN)
with when $f$ represents distance (L2) or similarity function (cosine).

Once you obtain embeddings for all the datapoints in your dataset, you can then
perform a semantic query by first encoding the query input into the embedding
space (using the encoder model) and then performing k-Nearest Neighbour search.
Practically, if your dataset fits in memory, you can do this with a simple
matrix multiply (for cosine similarity via `torch.matmul(x, X.T)`), with
database plugins (such as [pgvector](https://github.com/pgvector/pgvector) or
[sqlite-vec](https://github.com/asg017/sqlite-vec)). If your dataset doesn't
fit in memory, you can use more advanced techniques (e.g. approximation
algorithms); existing solutions include
[FAISS](https://github.com/facebookresearch/faiss),
[Milvus](https://milvus.io/), and other vector-DBs.

Retrieval is typically a bit more involved than a simple k-NN. One
common and simple extension is to combine exact search text retrieval
techniques (e.g. BM-25; see [SQLite's
documentation](https://sqlite.org/fts5.html) for a good introduction).
To do this, you need to combine ("re-rank") the search retrieval results in
some manner, which can be done via a learned function or simple heuristics
(e.g. Reciprocal Rank Fusion (RRF), see a practical example using [sqlite-vec](https://github.com/liamca/sqlite-hybrid-search?tab=readme-ov-file)).
Other extensions include filtering by metadata (for hard constraints), e.g. if
the input query is "how to read a file in Python" the "in Python" is classified as a
hard constraint, enforcing a filter to only include results relevant to the
Python programming language. Metadata can be predicted by another model (e.g.
[GLiNER](https://github.com/urchade/GLiNER)), this task is referred to as
"Entity Extraction", which could also be solved with a decoder-only LLM too
(with fine-tuning or prompt-engineering, there's probably a paper covering
this<sup>*</sup>).

<sup>\* Most low-hanging fruit ideas I had in this space had a paper: "you
could fine-tune a decoder LLM to encode text" - oh there's a series of papers
covering this already, "you could use the same LLM for generative and
embeddings without generative performance regressing" - oh there's a paper for this
(GRIT).</sup>

# How Can You Make a Decoder an Encoder?

A decoder can be made into an encoder by performing fine-tuning in a specific
manner, this fine-tuned/adapted model can deliver the same generative
performance if you train with a next-token objective jointly with an embedding
loss function (contrastive loss). I'll summarize how to do so below. Without
fine-tuning, the following approach doesn't work well (step 3), even for an
instruction-tuned model; ablations in [E5-V](https://arxiv.org/pdf/2407.12580)
(Table 6) show this.


The following are my summarized notes on how to perform fine-tuning to
transform a decoder-only transformer into an encoder, from the papers: (text-only)
[GRIT](https://arxiv.org/pdf/2402.09906),
[NV-Embed](https://arxiv.org/pdf/2405.17428), and (multi-modal)
[GME](https://arxiv.org/pdf/2412.16855),
[E5-V](https://arxiv.org/pdf/2407.12580):
1. Use a specific set of instructions to distinguish between generative and
   embedding modes, different types of tasks, document sources (e.g. Wikipedia,
   Arxiv), and different modalities (text, image, audio, video, etc.):
    * For Generative and Embedding modes:
        * Create a new token to enable the model to enter "embedding" mode (e.g. `<|embed|>`), and/or use a sequence of tokens e.g. `"Represent"` in the system prompt
    * For different modalities, you can influence the model to refer to the
      same semantic space, e.g. [E-5V](https://arxiv.org/pdf/2407.12580) embeds
      text and images into the embedding space via the following instructions:
        * Text input: `"<text> Summary of the above sentence in one word"`
        * Image input: `"<image> Summary of the above image in one word"`
    * Different types of tasks and document sources (see Section P in [GRIT](https://arxiv.org/pdf/2402.09906)'s Appendix), examples:
        * Clustering Reddit posts: "Identify the topic or theme of Reddit posts based on the titles"
        * Retrieval on Wikipedia: "Represent the climate-based claim to find a Wikipedia abstract to support it"
2. (Optional) alter the architecture of (M-)LLM to use bi-directional attention
   for "encoding" mode. This is shown to improve the resulting embedding
   quality w.r.t retrieval and other task metrics. 
    * If in "generative" mode, you can disable bi-directional attention and use casual attention for inference and training.
    * Note, [GME](https://arxiv.org/pdf/2412.16855) has ablations that show
      the reverse is true (i.e. bi-directional attention hurts performance),
      perhaps due to not training jointly and/or full model training not being employed.
3. To obtain an embedding for an input sample:
    * Without bi-directional attention: 
        - Use the last hidden state of the last output token, e.g. with HuggingFace:
            ```python
            emb = model(**inputs, output_hidden_states=True, return_dict=True)["hidden_states"][-1][:, -1, :]
            emb = F.normalize(emb, dim=-1)
            ```
    * With bi-directional attention:
        - Perform a mean pool across all hidden states for the last output
          token. This is empirically better than the above for bi-directional attention.
4. Loss: 
    * Embedding loss: use a contrastive loss (InfoNCE is commonly used), denote this as $L_\text{Rep}$
    * For the case where you train generative jointly, you can combine losses
      in the typical manner, e.g. as done in GRIT: $$L_\text{GRIT} = \lambda_\text{Rep}L_\text{Rep} + \lambda_\text{Gen}L_\text{Gen}$$
5. To optimize the M-LLM: use LoRA, QLoRA, or perform full fine-tuning. 
    * Warning: if you are not training jointly, then full fine-tuning may not
      perform as well as LoRA/QLoRA. I suspect this is because generative
      performance regresses more when tuning all weights of the model, and
      hence language understanding regresses, which is correlated with embedding
      performance.

# How Well Does it Work? Overview of Results

The [MTEB benchmark](https://huggingface.co/spaces/mteb/leaderboard) serves as
a standard benchmark for evaluating embedding quality on a wide variety of
benchmarks and tasks across numerous datasets. You can take a deeper look for yourself on the [leaderboard](https://huggingface.co/spaces/mteb/leaderboard). 

Here's a comparison of models for Retrieval in MTEB for Text-to-Text Retrieval:

| Model Name        | # Params | Mean    | T->T  (multi-lingual) | T->T (eng)
|:------------------|:-------------|:--------|:-------|:-----
| [all-mpnet-base-v2](https://huggingface.co/sentence-transformers/all-mpnet-base-v2) | 109M | 38.68 | 32.81 | 44.54
| [GritLM-7B](https://huggingface.co/GritLM/GritLM-7B) | 7B | 56.63 | 58.31 | 54.95
| [gte-Qwen2-1.5B-instruct](https://huggingface.co/Alibaba-NLP/gte-Qwen2-1.5B-instruct) | 1.5B | 55.52 | 60.78 | 50.25
| [inf-retriever-v1-1.5b](https://huggingface.co/infly/inf-retriever-v1-1.5b)<sup>2</sup> | 1.5B | 61.90 | 62.96 | 60.83
| [gte-Qwen2-7B-instruct](https://huggingface.co/Alibaba-NLP/gte-Qwen2-7B-instruct) | 7B | 59.09 | 60.08 | 58.09
| [inf-retriever-v1](https://huggingface.co/infly/inf-retriever-v1)<sup>2</sup> | 7B | 65.28 | 66.48 | 64.07
| [NV-Embed-v2](https://huggingface.co/nvidia/NV-Embed-v2) | 7B | 59.78 | 56.72 | 62.84
| [voyage-3](https://blog.voyageai.com/2024/09/18/voyage-3/) | Unknown | 59.80 | 66.13 | 53.46
| [gemini-embedding-exp-03-07](https://developers.googleblog.com/en/gemini-embedding-text-model-now-available-gemini-api/) | Unknown | **66.03** | **67.71** | 64.35
| [Seed1.5-Embedding](https://huggingface.co/ByteDance-Seed/Seed1.5-Embedding)<sup>3</sup> | Unknown | N/A | N/A | **67.45**

<sup>1. GritLM is based on Mistral-7B from 2023 and is now [deprecated and retired](https://docs.mistral.ai/getting-started/models/models_overview/#legacy-models).</sup><br>
<sup>2. This model is gte-Qwen fine-tuned further, showing that dataset quality and quantity matter.</sup><br>
<sup>3. These results are not published on the MTEB leaderboard, but their results are shown on their [model page](https://huggingface.co/ByteDance-Seed/Seed1.5-Embedding)</sup>

Here's how different multi-modal model approaches compare for Text-to-Image (T<->I) Retrieval (in any direction):

| Model Name        | # Params | Mean    | T<->I (multi-lingual) | T<->I (eng) | ZS Classification |
|:------------------|:-------------|:--------|:-------|:------------|:----
| [siglip-so400m-patch14-384](https://huggingface.co/google/siglip-so400m-patch14-384) | 878M |  **53.43** |40.19|49.27|**70.84**
| [CLIP-ViT-bigG-14-laion2B-39B-b160k](https://huggingface.co/laion/CLIP-ViT-bigG-14-laion2B-39B-b160k) | 2B | 49.12|28.01|**49.97**|69.37
| [e5-v](https://huggingface.co/royokong/e5-v) | 8B           | 52.87| **66.57** |42.03|50.01

Unfortunately, GME results are not available on the public leaderboard, but if
you trust their results on their [HF page](https://huggingface.co/Alibaba-NLP/gme-Qwen2-VL-2B-Instruct), GME
performs better than E5-V by approximately ~20% for T->I and I->T (English).

Interestingly, zero-shot classification performance of E5-V is much weaker compared to CLIP, but
multi-lingual performance for text to image retrieval is significantly higher
than the CLIP alternative, likely due to the stronger language model or simply
the LLM's pre-training dataset.

# Conclusion

To conclude, decoder-only transformers can be trained into strong SoTA
encoders. You don't need to depend on proprietary models: you could train an
encoder using the plethora of open-source M-LLMs released by research labs as a
base. The model architecture and weights you end up using are dependent on your
requirements and compute constraints, so evaluate it for yourself.

If you're still using SBERT (e.g.
[all-mpnet-base-v2](https://huggingface.co/sentence-transformers/all-mpnet-base-v2)),
consider a decoder-only transformer as an encoder instead.


---
title: "EgoVLP"
tags: paper-notes
source: https://arxiv.org/abs/2206.01670
code: https://github.com/showlab/EgoVLP/
---


Summary is:
- Highlights challenges with narrations:
  - 1) Same action occurs in different scenarios/videos, e.g. using a phone
  - 2) Different action occurring in the same scenario (temporally close)
    - 2 is a hard-negative
- Frozen architecture used for end2end training (weights not frozen, arch named
  "Frozen")
- In a batch: positive examples are classified as having 1 shared common noun and verb
- Augment random batch via adding hard-negatives, via temporally close examples (addressing challenge #2)
- Zero-shot tasks:
  - Ego-Charades
  - Video-retrieval tasks: EPIC-Kitchens-100, HowTo100M, CC3M+WebVid2M
- Ego4D Tasks (fine-tuned)
  - State change classification
  - NLQ - good performance increase
  - Moments queries

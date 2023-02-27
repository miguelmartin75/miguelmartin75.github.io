---
title: Galactica
source: https://www.galactica.org/static/paper.pdf
code: https://github.com/paperswithcode/galai
tags: paper ml
---

Related: [[LLMs]]

- Trained on a (relatively) small but high quality dataset
	- ~100M tokens
	- Scientific papers, code, knowledge bases, prompts
- Model size: up to 120B
- 30B model beats PaLM on MMLU and MATH
- Prediction of citations work better than sparsely/densely trained models
- Performance
	- 30B: 46.6% weighted, 42.7% unweighted
	- 120B: 48.7% weighted, 45.3% unweighted
- Notable arch design decisions
	- No biases
	- GeLU activation
	- Learn positional encodings
	- Context window -- what is this?
- Compute requirements:
	- 120B, CPU:
		- 480GB RAM
		- 150s for 1 input and 2 outputs
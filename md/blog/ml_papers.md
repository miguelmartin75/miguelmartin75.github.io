---
title: Recommended Machine Learning Papers and Learning Resources
state: publish
date: "2024-03-28"
---
# Introduction

This is a filtered curation [of papers](#papers) that I found over the years that either inspire me, blow me away (revolutionize the way I think) or are an essential read for someone within the field. Some of these papers I have not personally read in detail. 

I have also included a section on [learning resources](#learning-resources) at the bottom of the post covering a wide variety of techniques, theory and underlying math.

There is an emphasis on vision and language based papers with bias on vision. There is additional bias on modern techniques and deep learning. This list does not cover fundamental algorithms, theory and techniques essential to the field of Machine Learning such as generalization theory, probability, optimization, convex optimization, etc.

# Papers
- Meta-Learning and Meta-analysis of techniques in the field
	- [Will we run out of data?](https://arxiv.org/pdf/2211.04325.pdf)
	- [Beyond neural scaling laws: beating power law scaling via data pruning](https://arxiv.org/abs/2206.14486)
- Architecture
	- [AlexNet](https://proceedings.neurips.cc/paper_files/paper/2012/file/c399862d3b9d6b76c8436e924a68c45b-Paper.pdf) (the "Deep Learning breakthrough" paper)
	- [Non-local Neural Networks](https://arxiv.org/abs/1711.07971): the "CV attention paper"
		- [Attention Is All You Need](https://arxiv.org/abs/1706.03762): the "NLP attention paper"
	- [ResNet](https://arxiv.org/abs/1512.03385): scalable architecture via skip connections (just keep adding more layers)
	- [ViT](https://arxiv.org/abs/2010.11929): applying transformers to vision
	- [ResNexT](https://paperswithcode.com/method/resnext-block): "the response to ViT"
	- [MViT](https://arxiv.org/abs/2104.11227)
	- [TimeSFormer](https://arxiv.org/abs/2102.05095)
	- [Pay Attention to MLPs](https://arxiv.org/abs/2105.08050)
- SSL/WSL & Feature-Representation Learning
	- MAE & modality extensions
		- [original paper (images)](https://arxiv.org/abs/2111.06377)
		- [VideoMAE](https://arxiv.org/abs/2203.12602)
		- [AudioMAE](https://github.com/facebookresearch/AudioMAE)
	- [DiffMAE](https://weichen582.github.io/diffmae.html)
	- [Omnivore and OmniMAE](https://github.com/facebookresearch/omnivore)
	- [ImageBind](https://imagebind.metademolab.com/)
	- [MAWS](https://github.com/facebookresearch/maws): **billion parameter ViTs pre-trained on billions of images**
		- MAWS = MAE + WSP (weak-supervised pre-training)
		- Authors produce a CLIP-variant: "MAWS CLIP"
		- Impressive performance on video activity detection (model is image-based); top-1: 86% K400, 74.4% SSv2
		- IMO: under-rated (only 58 stars, really?)
	- [DINO](https://paperswithcode.com/method/dino)
	- [CutLER](https://arxiv.org/abs/2301.11320), [VideoCutLER](https://arxiv.org/abs/2308.14710)
	- [V-JEPA](https://ai.meta.com/research/publications/revisiting-feature-prediction-for-learning-visual-representations-from-video/)
	- [InternVideo2](https://arxiv.org/pdf/2403.15377.pdf)
	- [Cookbook of Self-Supervised Learning](https://arxiv.org/abs/2304.12210)
	- See also: "Vision and Language"
- Generative Models
	- [BigGAN](https://arxiv.org/abs/1809.11096)
	- [GigaGAN](https://mingukkang.github.io/GigaGAN/)
	- [Diffusion](https://arxiv.org/abs/2006.11239)
		- [Diffusion Models are Auto-encoders](https://sander.ai/2022/01/31/diffusion.html): not a paper, but it is a well written blog post
	- [DALLE2](https://openai.com/dall-e-2), [DALLE3](https://cdn.openai.com/papers/dall-e-3.pdf)
	- [Imagen](https://imagen.research.google/) (does not use CLIP)
- (Neural) Compression
	- [Neural Texture Compression](https://research.nvidia.com/labs/rtr/neural_texture_compression/)
	- [Compact-NGP](https://research.nvidia.com/labs/toronto-ai/compact-ngp/)
- 3D
	- Pre-read: [SfM](https://cmsc426.github.io/sfm/)
	- NeRF
		- [original paper](https://arxiv.org/abs/2003.08934), extension: [mipnerf](https://github.com/google/mipnerf)
		- [Instant Neural Graphic Primitives (instant-ngp)](https://github.com/NVlabs/instant-ngp)
		- [RawNeRF](https://bmild.github.io/rawnerf/)
		- https://localrf.github.io/
	- Gaussian Splatting (a "real-time NeRF")
		- [Original paper](https://repo-sam.inria.fr/fungraph/3d-gaussian-splatting/)
		- [Dynamic scene rendering](https://guanjunwu.github.io/4dgs/)
- Downstream Image Tasks (classification, object detection, tracking, segmentation, etc.)
	- [SegmentAnything (SAM)](https://segment-anything.com/)
	- [XMem](https://github.com/hkchengrex/XMem)
	- [TrackAnything](https://github.com/gaomingqi/Track-Anything)
	- [ViTPose](https://github.com/ViTAE-Transformer/ViTPose): higher resolution model is better
	- [Object Detection in 20 Years: A Survey](https://arxiv.org/pdf/1905.05055.pdf)
- Vision & Language
	- [CLIP](https://openai.com/research/clip)
		- **Mind-blowing zero-shot classification capabilities**
		- The model that initially enabled DALLE & Stable Diffusion.
		- This pre-training method improves [robustness](https://paperswithcode.com/task/adversarial-robustness) of learnt features (w.r.t classification accuracy on downstream task)
		- Extensions: [SigLIP](https://arxiv.org/abs/2303.15343)
	- [MM1](https://arxiv.org/abs/2403.09611): Apple's extension to LLaVa with a good number of experiments/ablations
	- [LLaVa](https://llava-vl.github.io/)
- LLMs
	- [PaLM](https://arxiv.org/pdf/2204.02311.pdf): showing that LLMs have emergent properties/behaviors that only occur with scale (e.g. reasoning, humor)
	- [GPT-2](https://openai.com/research/gpt-2-1-5b-release)
	- [[OPT]]: Meta's "first attempt" at LLMs
	- [[Galactica]]: showing that with good quality data you can out-perform other models trained on more data
	- [LLaMa](https://arxiv.org/abs/2302.13971), [LLaMa2](https://arxiv.org/abs/2307.09288)
	- [Gemini](https://arxiv.org/abs/2312.11805)
- Audio
	- [whisper](https://arxiv.org/pdf/1905.05055.pdf)
	- [CLAP](https://github.com/LAION-AI/CLAP)
- Engineering
	- [llama.cpp](https://github.com/ggerganov/llama.cpp), [ggml](https://github.com/ggerganov/ggml)
	- [nanoGPT](https://github.com/karpathy/nanoGPT)
	- [clip.cpp](https://github.com/monatis/clip.cpp)
	- [litgpt](https://github.com/Lightning-AI/litgpt)
	- [gradient checkpointing](https://github.com/cybertronai/gradient-checkpointing)
- Public Datasets
	- [LAOIN-5B](https://laion.ai/blog/laion-5b/)
	- [conceptual captions](https://github.com/google-research-datasets/conceptual-12m)
	- [Ego4D and Ego-Exo4D](https://github.com/facebookresearch/Ego4d/)

# Resources for Learning (Theory)

- [MIT Deep Learning Book](https://www.deeplearningbook.org/)
- [Tutorial on Diffusion Models for Imaging and Vision](https://arxiv.org/pdf/2403.18103.pdf)

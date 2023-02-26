---
title: Non-Local Networks
state: dirty
source: https://arxiv.org/abs/1711.07971
tags: paper ml
---

The paper proposes a family of building blocks for capturing long-range dependencies. The non-local operation is computed as a weighted sum of features at all positions. For video - non-local model and compete with state of the art in Kinetics and Charades datasets. In static image recog - non-local models improve object detection/segmentation and pose estimation on COCO

Recurrent and convolutional ops process a local neighbourhood - either in space or time. Thus to capture long-range dependencies, they must be repeated, propagating signals throughout. Limits of this repetition include computational inefficiency, and optimisation difficulties.

A non-local op computes the response as a weighted sum of all features at all positions in the input feature maps. The set of positions can be space, time or spacetime; applicable for image, sequence and video problems (respectively). Even with a few layers they obtain reasonable results. The non-local operations maintain variable input sizes and can be computed with other operations (other than FC), such as a conv layer, which they do utilise.

With a few non-local blocks, video classification is better than 2D and 3D convolutional networks.

The classical non-local means method (in computer vision) is a filtering algorithm that computes a weighted mean of all pixels in an image. It allows distance pixels to contribute to the filtered response. BM3D (block-matching 3D) is a non-local filtering idea for de-noising, and it does a pretty good job, performing well with the state of the art deep networks and even used in some deep networks initially. Non-local matching can also be utilised for texture synthesis, super-resolution and inpainting algos.

Long-range dependencies can also be modelled with graphical models (e.g. CRF)

This work is also related to self-attention for machine translation. Self-attention computes responses at a position in a sequence by attending to all positions and taking their weighted average in the embedded (feature) space. Self-attention can be viewed as a form of a non-local mean operation. i.e. this basically generalises it for other problems

Other video classification architectures Combine CNN and RNN Utilise 3D convs in spacetime Optical flow and trajectories can be helpful Both flow and trajectories are off-the-shelf modules that may find long-range non-local dependencies Comparison of models can be found here (section below: Quo Vadis)

Non-local mean formulation

i is the index of an output position (time, space or spacetime), whose response is to be computed. j represents all other possible positions, x is the input signal (image, sequence, video; moreso their features). y is output signal; C(x) is a normalising factor. f represents the weight of dependence between the two input signals, i.e. the weight in a weighted sum and finally g provides a representation of xj

Non-local op is different to a fully connected (fc) layer and conv layer Conv layer, all js are not considered, only the local neighbour, e.g. i - 1 <= j <= i + 1 Fc layer, relationships between two input signals are function but not in fc (it is just a weight)

Forms of f and g

Embedding (f)

They use a simple linear embedding, g(x) = Wx, where W is a weight matrix, implemented as a 1x1 conv layer or 1x1x1 (for spacetime)

Pairwise (f)

Gaussian, f(xi, xj) = exp(xiT xj) Could also use euclidean distance but dot product is more implementation friendly Embedded gaussian Same as above but with a linear embedding And others, such as embedded dot product, etc.

I believe the authors end up using Gaussian

They use the above equation as a residual block, i.e. they do: Zi = Wyi + xi

To apply it to many architectures that are pre-trained, without breaking it’s initial behaviour (iff W is initialized to zero)

---

They compare to two types of models:

C2D Basic CNN, where temporal information is addressed only in pooling layers I3D Inflates the above model to 3D, e.g. 2D conv kernel k*k turns to t*k*k Can be init from a 2D model by dividing the weights by t so that activations stay around the same Basically what Quo Vadis does Consider a single frame spanning t frames => would result in the same as a 2D model operating on the single frame

With these two models they apply non-local blocks to them for comparison, and compare how many non-local blocks is optimal

tl;dr:

Adding non-local blocks is better, but by a small margin (~1-3%) but it is consistently better In kinetics dataset, it performs much better than the baseline (around 2-5% improvement) Applying them to spacetime is better But if you have to choose space or time -- either one is fine

Non-local 2D conv is better than a normal 3D conv net Non-local 3D conv is best

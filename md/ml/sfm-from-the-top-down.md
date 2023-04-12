---
title: SfM from Scratch
tags: ml post teach
state: doing
---

# Structure from Motion from The Top Down #todo

- [ ] intro
- [ ] solutions
	- [ ] COLMAP
Refs:
- [[Structure-from-Motion Revisited (COLMAP paper)]]

## Introduction

- SfM enables you to learn camera poses with respect to time on an (approximately) constant scene
- This is useful for a lot of downstream applications, notably NeRFs
- The de-facto solution in the community is COLMAP (TODO paper ref)
- This leaves me with a question: how does it work? Can we implement it? Can we do better than COLMAP?

# Background
## Camera Parameters

source: https://docs.opencv.org/4.x/dc/dbb/tutorial_py_calibration.html

intrinsic parameters are associated to the camera itself (focal length, optical centers):
$$
\begin{bmatrix}
f_x & 0 & c_x \\
0 & f_y & c_y \\
0 & 0 & 1
\end{bmatrix}
$$

Extrinsic parameters correspond to rotation and translation vectors, which allow you to translate a 3D point to a coordinate system

## Survey of SfM

- you can end2end learning camera poses or implicitly for the downstream application for a NeRF


## Implementing SfM from Scratch with Python

### The data
TODO

### Feature Extraction
- Let's not use SIFT features, we'll start off with learned features
- Let's use COLMAP to verify these work

###  Feature Matching

Well, we can simply use COLMAP.
---
title: Structure-from-Motion Revisited
source: https://demuc.de/papers/schoenberger2016sfm.pdf
code: https://github.com/colmap/colmap
tags: paper ml
---
Steps of incremental SfM:
- Feature extraction and matching
	- matching is either exhaustive or heuristically done based on some methods
- Geometric verification (TODO revisit)
	- Matching may contain lots of false positives (no correlation)
	- SfM verifies the matching by trying to estimate a transformation between images using projective geometry
	- RANSAC used for outliers
	- Output: geometrically verified image pairs $\hat{C}$ , the output of the stage is a "scene graph" with images as nodes and verified pairs of images as edges
		- decision criterions GRIC and QDEGSAC
- Incremental reconstruction
	- Initialize with a carefully chosen two-view reconstruction
	- "Carefully" as once chosen, you may not be able to recover from a bad initialization
		- Dense location in the image graph, with many overlapping cameras, due to increased redundancy
- Image registration
	- Solve PnP problem using feature correspondences to triangulated points in already registered images. 
	- Estimate pose $P_c$ and it's intrinsic parameters. Set $P$ is extended by the pose $P_c$ of the newly registered image. 
	- Pose is estimated with RANSAC due to outliers
- Triangulation of scene points
	- 
- Bundle adjustments
	- 
- Refine reconstructing using bundle adjustment (BA)
	- 
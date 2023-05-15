---
title: Neural Lens Modeling
source: https://arxiv.org/pdf/2304.04848.pdf
---

- INN to model: distortion, and camera intrinsics and extrinsics
	- Residual network used with 4 blocks. Each block composed of TODO
	- Used because 
	- NOTE: INNs used in normalizing flows, which computes Jacobian for generative task. This is not required here.
	- width of 1024. I assume a FC=
- Can be optimized using ArUco codes or a 3D construction pipeline (NeRF? TODO confirm)
- Method
	- Pinhole:
		- $X\in R^3$  in 3D world space
		- $x \in R^2$ on camera sensor
		- projection: 2D pixel coordinate $x$ is obtained via:
			- $x = C(X) = \text{norm}(K * (R*X + t))$
			- $\text{norm}(x) = (x[0]/x[2], x[1]/x[2])$
			- $R$ and $t$ are rotation and translation vectors
			- $K$ is the intrinsics matrix
	- Pinhole assumes straight line from world to camera. This is not the case.
	- To model non-linear distortion:
		- map ideal coordinates $(u_x, u_y)$ (from pin-hole? TODO confirm) to distorted coordinates $(d_x, d_y)$
			- Using a [diffeomorphic](https://en.wikipedia.org/wiki/Diffeomorphism) function
				- Maps between two manifolds, is invertible function
				- assumes manifolds are differentiable
		- $x = \text{norm}(K * hom(D(u)))$
	- D is modelled with an invertible network
- Optimization
	- Geometric loss using known 3D coordinates (in practice, initial estimates can be obtained - TODO not sure how)
		- Supervised learning with 3D - 2D pairs with L2 loss
	- Photometric Loss
		- Color predicted by $C_{\theta}(X_{\text{3d}})$ should match color of the point $X$ projected there (assuming constant lightning, exposure and Lambertian marker material)
	- NeRF can be trained with this model, jointly optimizing it's parameters

FisheyeNeRF dataset

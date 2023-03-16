---
title: K-Planes Explicit Radiance Fields in Space, Time, and Appearance
source: https://arxiv.org/pdf/2301.10241.pdf
code: https://github.com/sarafridov/K-Planes
website: https://sarafridov.github.io/K-Planes/
---

Summary
- White-box model for radiance fields in arbitary dimensions
- Uses d choose 2 planes to represent a d-dimensional scene
- Works on:
	- d = 2 => 2d image
	- d = 3 => 
		- 3d volume
		- 3d volume with variable appearance (e.g. different weather)
	- d = 4 => video
- Challenge
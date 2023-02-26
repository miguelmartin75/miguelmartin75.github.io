---
title: Signed Distance Fields
tags: study
---

- https://developer.nvidia.com/gpugems/gpugems3/part-v-physics-simulation/chapter-34-signed-distance-fields-using-single-pass-gpu
- https://www.youtube.com/watch?v=QgzxBN1m9WE

A field which stores signed distances to the surface. If inside of the surface it is negative. If outside it is positive. If on the surface it is 0.

A field is essentially a matrix of values (pixels) or voxels for 3D surfaces.

# Uses

- Collision detection in cloth animation
- Multi-body dynamics
- Deformable objects
- Mesh generation
- Motion planning
- Sculpting
- Text rendering
	- Used to determine if a pixel should be turned on or off.

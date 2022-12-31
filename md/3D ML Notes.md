---
title: Machine Learning + 3D
---

# 3D Scan Data & Papers

## Environments

- [https://aihabitat.org/](https://aihabitat.org/)

## General

- [KinectFusion](https://www.microsoft.com/en-us/research/wp-content/uploads/2016/02/ismar2011.pdf)
  

## Objects

Methods/Papers

-   Apple's [ObjectCapture](https://developer.apple.com/videos/play/wwdc2021/10076/)
  

## Datasets

-   [Redwood-3DScan](https://github.com/isl-org/redwood-3dscan)
-   [https://paperswithcode.com/dataset/ycb-video](https://paperswithcode.com/dataset/ycb-video)
  

## Hands

-   [FreiHAND](https://arxiv.org/pdf/1909.04349.pdf)
-   Data collection: Semi-automated human in the loop annotations
-   GHUM (also for people)

## Humans/Avatars

Scanners (Hardware)

-   [http://www.shapeanalysis.com/CAESAR.htm](http://www.shapeanalysis.com/CAESAR.htm)
-   [3dMD](https://3dmd.com/)
-   [MPI Dynamic FAUST](https://dfaust.is.tue.mpg.de/) custom setup (BUFF paper)

-   Their custom setup is 22 RBG cameras and 22 LED panels in an array. Not realistic unless there’s a common setup location for data collection.
-   Lots of markers on the humans

If a shared environment (i.e. for EgoExo), then bigger hardware setups might be practical if budget allows.

### Datasets, Methods, Collections Methods

tl;dr

-   Current 3D datasets exist with and without (image/video, 3D scan) pairs
-   3D reconstruction methods use multiple datasets for training (such as H-NeRF, [PIFuHD](https://arxiv.org/pdf/2004.00452v1.pdf))
-   to collect data:
	-   Proprietary hardware is used (e.g. BUFF, SCAPE, GHUM), or
	-   "Calibration"-like data is captured
	-   Camera array from multiple views/perspectives (e.g. 22 cameras), or
	-   Captured from a single view where the subject moves around (e.g. PeopleSnapshot dataset)
	-   Optionally (e.g. for RenderPeople) a 3D model is made from artists (i.e. through annotations)
-   Synthetic datasets (AGORA, SURREAL)
  

Proprietary hardware includes: Caesar, 3dMD, Cyberware Wholebody scanner

I believe we should try to collect "calibration" data, if possible, from a multi-camera view. If anyone else has any other opinions or suggestions, let me know.

A lot of papers use [SMPL-X](https://smpl-x.is.tue.mpg.de/) (or SMPL), a parametric 3d human model, which seems to be from the same lab as AGORA (see below)

-   alternative 3D model is imGHUM (H-NERF uses it), which is a learnable 3D model
-   [PIFuHD](https://arxiv.org/pdf/2004.00452v1.pdf) (1)
-   Reconstruction of 3D human model with one image
-   Uses RenderPeople data & makes a Synthetic dataset using this dataset
-   [HierarchicalProbabilistic3DHuman](https://github.com/akashsengupta1997/HierarchicalProbabilistic3DHuman)
-   Agora, SMPL-X
-   [End-to-End Human Pose and Mesh Reconstruction with Transformers](https://openaccess.thecvf.com/content/CVPR2021/papers/Lin_End-to-End_Human_Pose_and_Mesh_Reconstruction_with_Transformers_CVPR_2021_paper.pdf)
-   [GHUM](https://openaccess.thecvf.com/content_CVPR_2020/papers/Xu_GHUM__GHUML_Generative_3D_Human_Shape_and_Articulated_Pose_CVPR_2020_paper.pdf) (google research)
	-   Caesar data used
-   [imGHUM](https://arxiv.org/pdf/2108.10842.pdf)
	-   Generative model of 3D human shape and pose represented as a signed distance field
	-   Introduces GHS3D
-   [H-NeRF](https://arxiv.org/pdf/2110.13746.pdf)
	-   Uses a camera array to reconstruct humans
	-   Based on imGHUM
	-   Temporal reconstruction of humans in motion
	-   Works on monocular video or sparse set of cameras
-   [PeopleSnapshot](https://graphics.tu-bs.de/people-snapshot): The cheapest/easiest method for data collection
	-   This is essentially “calibration” data, which may be valuable
	-   Subjects rotate around a camera
-   [BUFF](https://buff.is.tue.mpg.de/) uses 3dMD and a custom setup. Described on MPI Dynamic FAUST
-   [Humans3.6M](http://vision.imar.ro/human3.6m)
-   3D laser scans of 11 actors
-   Accurate 3D joint positions and joint angles
-   Setup is a camera array in a "lab" setting (see: [http://vision.imar.ro/human3.6m/description.php](http://vision.imar.ro/human3.6m/description.php))
-   4 RGB cameras, 10 motion cameras, 1 time-of-flight sensor (TODO what is time-of-flight)
-   [SCAPE](http://ai.stanford.edu/~drago/Papers/shapecomp.pdf) - uses Cyberware Wholebody scanner
-   Also see: [https://www.sciencedirect.com/topics/engineering/cyberware](https://www.sciencedirect.com/topics/engineering/cyberware)
-   [RenderPeople](https://renderpeople.com/about-us/) data: used by some papers, such as 1
-   RenderPeople collects their data with a camera array similar to above (with more cameras) and annotates in a 3D program (Maya, Zbrush, etc.)

Synthetic datasets
-   [AGORA](https://github.com/pixelite1201/agora_evaluation)
-   [surreal](https://www.di.ens.fr/willow/research/surreal/)


Other resources:
-   List of [human datasets](https://khanhha.github.io/posts/3D-human-datasets/)

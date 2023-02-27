---
title: A Survey on Deep Learning for Localization and Mapping
source: https://arxiv.org/pdf/2006.12567.pdf
tags: ml paper survey
state: doing
---

- Overview
	- Below components can be integrated into Spatial Machine Intelligence System (SMIS) to solve real-world challenges 
	- Odometry Estimation
		- calculate the relative change in pose w.r.t translation and rotation between two or more frames of sensor data
		- Tracks self motion
		- Process to integrate pose changes w.rt initial state to derive the global pose (position/orientation)
		- "Can be used to provide pose information and as a odometry motion model to assist feedback loop of robot control"
		- "deep learning is applied to model the motion dynamics in an end-to-end fashion or extract useful features to support a pre-built system in a hybrid way"
	- Global localization
		- Retrieves global pose of mobile agents in a known scene with prior knowledge
		- Achieved by matching inquiry input data with pre-built 2D or 3D map, other spatial references, or a scene that has been visited before
		- Can be 
	- Mapping
		- Builds / reconstructs a consistent model to describe the surrounding environment
		- DL used to discover scene geometry and semantics from raw data (images or otherwise)
		- Sub-divided into: geometric, semantic, general mapping
	- SLAM (localization and mapping)
		- jointly optimizes odometry estimation, global localization and mapping as one, to boost perf in localization and mapping
		- SLAM modules ***local optimization*** to ensure consistency of the entire system w.r.t camera motion and scene geometry
		- ***global optimization*** aims to constrain the drift of global trajectories
		- ***keyframe detection*** is used to enable efficient inference
		- ***loop-closure detection*** 
		- ***uncertainty estimation***: metric of belief in learned poses and mapping
- Personal notes per topic
	- Global localization might be useful for EgoExo

- Odometry Estimation
	- Visual Estimation

- pitch = requested bytes + padding ([source](https://stackoverflow.com/a/16119944))

## cuvid
https://docs.nvidia.com/video-technologies/video-codec-sdk/nvdec-video-decoder-api-prog-guide/

- cuvidDecodePicture instructs hardware to kick of decoding of the frame/field
- cuvidMapVideoFrame
	- gets the CUDA device pointer and pitch of the output service
# l4t-opencv

OpenCV 4.6.0 for Jetson (Linux for Tegra, l4t) with Docker.

Code: https://github.com/zauberzeug/l4t-opencv

Image: https://hub.docker.com/repository/docker/zauberzeug/l4t-opencv

## Usage

### Dockerfile

Most of the time you will use this image as base for your own Dockerfile:

```dockerfile
FROM zauberzeug/l4t-opencv:4.6.0-35.4.1

...
```

### Docker Run

```bash
docker run --rm -it --runtime=nvidia -e NVIDIA_VISIBLE_DEVICES=all zauberzeug/l4t-opencv:4.6.0-35.4.1 
```

### Docker Compose

```
version: "3.3"

services:
  opencv:
    image: "zauberzeug/l4t-opencv:4.6.0-35.4.1"
    environment:
      - NVIDIA_VISIBLE_DEVICES=all
    command: "/bin/bash"
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              capabilities: [gpu, utility]
```

## Build

On an Jetson with l4t r35.4.1, execute

```
docker build --build-arg MAKEFLAGS=-j6 --build-arg OPENCV_VERSION=4.6.0 -t zauberzeug/l4t-opencv:4.6.0-35.4.1 .
```

Make sure you have nvidia as the default runtime in `/etc/docker/daemon.json`:

```json
{
  "runtimes": {
    "nvidia": {
      "path": "nvidia-container-runtime",
      "runtimeArgs": []
    }
  },

  "default-runtime": "nvidia"
}
```

### ToDos

It would be nice to have it all in a `build.sh` file like https://github.com/dusty-nv/jetson-containers:

 1. checking runtime
 2. determining l4t version
 3. ... 
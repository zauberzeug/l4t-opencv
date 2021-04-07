# l4t-opencv

Docker image which provides openCV 4.5.0 for Jetson (Linux for Tegra, l4t).

# Usage

## Dockerfile

Most of the time you will use this image as base for your own Dockerfile:

```
FROM zauberzeug/l4t-opencv:4.5.0-r32.4.4

...
```

## Docker Run

```
$ docker run --rm -it --runtime=nvidia -e NVIDIA_VISIBLE_DEVICES=all zauberzeug/l4t-opencv:4.5.0-r32.4.4 bash
```

## Docker Compose

```
version: "3.3"

services:
  opencv:
    image: "zauberzeug/l4t-opencv:4.5.0-r32.4.4"
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

# Build

We use drone to automatically build this image. If you want to do it by hand, execute

```
docker build --build-arg MAKEFLAGS=-j6 --build-arg VERSION=4.5.0 -t l4t-opencv:test .
```
# l4t-opencv

Docker image which provides openCV 4.5.0 for Jetson (Linux for Tegra, l4t).

# Usage

## Docker Run

````
$ docker run --rm --runtime=nvidia -e NVIDIA_VISIBLE_DEVICES=all zauberzeug/l4t-opencv:4.5.0-r32.4.4 bash
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
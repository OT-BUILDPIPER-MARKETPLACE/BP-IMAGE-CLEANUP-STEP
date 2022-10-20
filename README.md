# BP-IMAGE-CLEANUP-STEP
I'll cleanup all the prior tags of the recently created image

## Setup
* Clone the code available at [BP-IMAGE-CLEANUP-STEP](https://github.com/OT-BUILDPIPER-MARKETPLACE/BP-IMAGE-CLEANUP-STEP)
* Build the docker image
```
git submodule init
git submodule update
docker build -t ot/image_cleanup:0.1 .
```
* Do local testing
```
docker run -it --rm -v /var/run/docker.sock:/var/run/docker.sock -e IMAGE_NAME="nginx" -e IMAGE_TAG=stable-alpine ot/image_cleanup:0.1
```

## Reference
* [Docker Images](https://docs.docker.com/engine/reference/commandline/images/)
* [Docker Image Prune](https://docs.docker.com/engine/reference/commandline/image_prune/)
* [Docker tags](https://docs.docker.com/engine/reference/commandline/tag/)
* Reference examples
```
docker image prune --filter "until=24h"
docker image prune --filter="label=deprecated"
docker images nginx --filter "before=nginx:stable-alpine"
docker images nginx --filter "before=nginx:stable-alpine" --format "{{.Tag}}"
```
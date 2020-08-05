# Bitbake Docker

[![Docker Pulls](https://img.shields.io/docker/pulls/elcfd/openwrt-builder)](https://hub.docker.com/r/elcfd/openwrt-builder)

This project creates a docker image which can be used as a containerized build environment for the [Openwrt project](https://openwrt.org/).

## Features
* Containerized build environment without user permission issues
* The **ncurses** dev package is installed allowing **menuconfig** to be used inside the container
* [Dumb init](https://github.com/Yelp/dumb-init) is used to make sure that the build processes receive the correct signal to terminate

## Running in docker

Pull the image from docker hub:

```
docker image pull elcfd/openwrt-builder:latest
```

To run the container:

```
docker container run -it --rm -v /workdir:/workdir elcfd/openwrt-builder:latest
```

Where **/workdir** is the location on the host PC that is going to be mounted into the build container.

**NB.** The workdir passed into the container, can be any valid path on the host but must not be owned by the root user.

If the previous command was successful the shell will now be inside the container:

```
builder@b4e96c8d231c:/workdir$
```

**NB.** On most docker images the default user inside a docker container is root. This causes permission issues when mounting a folder from the host to inside a container. This image is built
so that when the container is started the ownership permissions on the folder being passed into the container are reflected inside the container. This means that switching between the folder
on the host and inside the container is seamless.

## Building Openwrt

1. Clone the Openwrt project:

```
builder@b4e96c8d231c:/workdir$ git clone https://git.openwrt.org/openwrt/openwrt.git
```

**NB.** The Openwrt project must be cloned into `/workdir/openwrt/` as this is the path the build container expects in order to complete a build.

2. Checkout the latest stable release:

```
builder@b4e96c8d231c:/workdir/openwrt$ git checkout <tag>
```

3. Update the feeds:

```
builder@b4e96c8d231c:/workdir/openwrt$ ./scripts/feeds update -a
```

4. Install the feeds:

```
builder@b4e96c8d231c:/workdir/openwrt$ ./scripts/feeds install -a
```

5. Setup configuration for the build target:

```
builder@b4e96c8d231c:/workdir/openwrt$ make menuconfig
```

6. Build:

```
builder@b4e96c8d231c:/workdir/openwrt$ make -j$(nproc)
```

The resulting images will be under `bin/target/**/**/` folder.

## Development

The following dependencies are required for development:
* docker
* [task](https://taskfile.dev/#/installation?id=install-script)

### Building the Images

The Dockerhub image parameters are specified at the top of the [image creator](image_creator.sh) so if required edit this.

The command to build is:

```
task build
```

### Pushing the Built Images to Docker Hub

The command to push the built images is:

```
task release
```

**NB.** Successful authentication with Dockerhub must have been completed before running this command.

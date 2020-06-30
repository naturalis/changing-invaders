# docker information

Docker is a technology that allows one to execute programs in a way that there is control over its dependencies. docker is used in this project, since many different programs are used. Docker works with a dockerfile, which creates an docker image, that contains here all the programs (and configurations/data) used for this project.

The docker image created is a linux image. It might work on windows, but possibly takes effort. Also note that docker for linux requires a kernel module not used in the official linux kernel. This is not problematic when one uses the default Ubuntu kernel (or a general use linux distribution) but for possible less known linux, and when one builds the linux kernel itself, this might be useful to know. So if that is your case, try to build your(or find a) kernel with the kernel module 'aufs' patched to it.


The docker-image might be invoked using
```bash
docker build -t changing-invaders:v1.0 .
# local-data could of course be changed to every folder that contains your data and the files.yml file
docker run -v $PWD/local-data:/var/data/data -ti changing-invaders:v1.0 ./fastqTo100SNPs.sh
```
optionally one can directly see the results of ggplot (without writing to a file) using this method: first run on the host:
```
XSOCK=/tmp/.X11-unix
XAUTH=/tmp/.docker.xauth
xauth nlist :0 | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -
```
and then call docker with these arguments:
```bash
-v $XSOCK:$XSOCK -v $XAUTH:$XAUTH -e XAUTHORITY=$XAUTH
```
added after $PWD/local-data:/var/data/data
and within the container execute: `export DISPLAY=:0`
Of course this will not work on a Windows system or a system that has no X server available.

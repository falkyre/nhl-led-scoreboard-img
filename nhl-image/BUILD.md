## To update the packer arm image to include ansible

See the [Dockerfile](https://github.com/falkyre/nhl-led-scoreboard-img/blob/packer/Dockerfile)

```
docker image build --build-arg BUILDKIT_INLINE_CACHE=1 --progress=plain -t packer-builder-arm-ansible:vlatest .
```

There are two things required for the build.  You need to have a defined packer build configuration.  We are using the Hasicorp HCL2 language for this.  See the [raspios.pkr.hcl](https://github.com/falkyre/nhl-led-scoreboard-img/blob/packer/nhl-image/raspios.pkr.hcl) 

Also required is the ansible playbook, this is defined in the provisoner "ansible" section.  The playbook is where the magic occurs for installing everything the image needs to run the scoreboard software.  See the [playbook](https://github.com/falkyre/nhl-led-scoreboard-img/blob/packer/nhl-image/ansible/setup-raspberry.yml)

Once you have created the above image, you can now run your build.  

```
docker run -e TZ=America/Winnipeg --rm -it --privileged -v /dev:/dev -v ${PWD}:/build packer-builder-arm-ansible:vlatest build raspios.pkr.hcl
```

If you want to "test" your image without burning to an SD card and raspberry pi, you can use this docker image to mount the raspberry pi image and launch bash on it.  This uses Qemu to emulate the raspberry pi arm chip.

```
docker run --rm -it --privileged -v ${PWD}/rpios-scoreboard-V1.6.12.img:/usr/rpi/rpi.img -w /usr/rpi ryankurte/docker-rpi-emu:latest ./run.sh rpi.img /bin/bash
```
You can use this to endure that everything has been installed in the proper locations and even test some commands (but not the actual scoreboard code)

To speed image builds up, there are two proxy programs used.  One, apt-cacher-ng, is used to cache the OS packages.  The other is called proxpi and this caches PyPi python packages.  In the ansible playbook, they are defined under the variables section at the top of the playbook.  Once these were added to t he build, the build time for the image dropped from about 1 hour down to about 15 minutes.

[apt-cacher-ng](https://github.com/sameersbn/docker-apt-cacher-ng)
[proxpi](https://github.com/EpicWink/proxpi)
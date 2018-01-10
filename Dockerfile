FROM debian:stable-slim

ENV LC_ALL C.UTF-8
ENV DEBIAN_FRONTEND noninteractive

# requirements for the app
RUN apt-get update && apt-get install -y --no-install-recommends syslinux-common makebootfat unzip wget

COPY input/* /image/

RUN dd if=/dev/zero of=freedos.img bs=1M count=10
RUN wget http://www.ibiblio.org/pub/micro/pc-stuff/freedos/files/distributions/1.0/pkgs/commandx.zip ; wget http://www.ibiblio.org/pub/micro/pc-stuff/freedos/files/distributions/1.0/pkgs/kernels.zip ; wget http://www.ibiblio.org/pub/micro/pc-stuff/freedos/files/distributions/1.0/pkgs/unstablx.zip
RUN for i in *.zip ; do unzip "$i" ; done
RUN cp bin/command.com bin/kernel.sys /image/
RUN makebootfat -o freedos.img -E 255 -1 source/ukernel/boot/fat12.bin -2 source/ukernel/boot/fat16.bin -3 source/ukernel/boot/fat32lba.bin -m /usr/lib/syslinux/mbr/mbr.bin /image/

# maybe there is a better way to extract the generated image?
CMD ["/bin/true"]

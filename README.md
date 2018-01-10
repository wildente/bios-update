# simple bios update
i was once more annoyed how complicated bios updates are, when NOT using a redmond os. so i used some well known tools
to botch a freedos bootable mini image, which can be booted via grub+memdisk.

# supplied freedos.img

the freedos.img was build with the instructions below and contains the A22 bios update for dell e7240. do not use this bios
update file, if you are not sure it's the right one!

     $ sha512sum E7240A22.exe
     a5ef81a3c9f06420219555d88b9f2595bc183cf2854f0628334f5a459066c2b4a38221719a24f83faa39f3245b7f8849423598c4cb49284572c327178c541b6d  E7240A22.exe

# legal
no responsibility 
no liabilities
use at your own RISK!

if i am violating any copyright, please let me know and i will take it down.


# how to make your own disk / usage

     emerge -av syslinux makebootfat
     mkdir freedos
     cd freedos
     mkdir myroot
     
     dd if=/dev/zero of=freedos.img bs=1M count=10
     
     wget http://www.ibiblio.org/pub/micro/pc-stuff/freedos/files/distributions/1.0/pkgs/commandx.zip
     wget http://www.ibiblio.org/pub/micro/pc-stuff/freedos/files/distributions/1.0/pkgs/kernels.zip
     wget http://www.ibiblio.org/pub/micro/pc-stuff/freedos/files/distributions/1.0/pkgs/unstablx.zip
     for i in *.zip ; do unzip $i ; done
     
     cp bin/command.com bin/kernel.sys myroot/
     cp ~/Downloads/E7240A22.exe myroot/
     
     makebootfat -o freedos.img -E 255 -1 source/ukernel/boot/fat12.bin -2 source/ukernel/boot/fat16.bin -3 source/ukernel/boot/fat32lba.bin -m /usr/share/syslinux/mbr.bin myroot/
     
     cp freedos.img /boot
     cp /usr/share/syslinux/memdisk /boot
     
     cat >> /boot/grub/grub.cfg <<EOF
     menuentry "freedos bios update" {
      linux16 /memdisk
      initrd16 /freedos.img
     }
     EOF


# docker
i have added a dockerfile to generate an image. you might need to adjust the size of the freedos.img file,
if your bios update file is >9MB.


     # download your bios update file into the input/ directory.

     docker build -t bios:latest .
     docker run --name=bios-out bios:latest
     docker cp bios-out:/freedos.img output/

     docker rm -f bios-out
     docker rmi -f bios:latest

     # (optional, but recommended) test if the image works:
     qemu-system-x86_64 -enable-kvm -kernel /usr/share/syslinux/memdisk -initrd output/freedos.img

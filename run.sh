#!/usr/bin/env bash

DIR="$(realpath $(dirname "$0"))"
pushd output/ramdisk/
for f in "$@"; do
	cp $DIR/"$@" .
done
find . -print0 | cpio --null -ov --format=newc | gzip -9 > ../initramfs.cpio.gz
popd

qemu-system-x86_64 -kernel output/linux/arch/x86/boot/bzImage -nographic -append 'console=ttyS0 loglevel=15' -initrd output/initramfs.cpio.gz

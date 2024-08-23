.PHONY: all linux busybox
all: linux busybox

linux:
	mkdir -p output/linux
	cp kernel_config output/linux/.config
	$(MAKE) -C linux O=$(PWD)/output/linux

busybox:
	mkdir -p output/busybox
	cp busybox_config output/busybox/.config
	$(MAKE) -C busybox O=$(PWD)/output/busybox CC=musl-gcc
	$(MAKE) -C busybox O=$(PWD)/output/busybox CC=musl-gcc install CONFIG_PREFIX=$(PWD)/output/ramdisk

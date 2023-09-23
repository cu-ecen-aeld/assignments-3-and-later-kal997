#!/bin/bash
# Script outline to install and build kernel.
# Author: Siddhant Jajoo.

set -e
set -u

BUSYBOX_INSTALLED_FLAG=0
OUTDIR=/tmp/aeld
KERNEL_REPO=git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
PATCH_REPO=https://github.com/kal997/linux-v5.1.10-patch.git
KERNEL_VERSION=v5.1.10
BUSYBOX_VERSION=1_33_1
FINDER_APP_DIR=$(realpath $(dirname $0))
ARCH=arm64
CROSS_COMPILE=aarch64-none-linux-gnu-
CROSS_COMPILER_PATH=/home/khaled/arm-cross-compiler/gcc-arm-10.2-2020.11-x86_64-aarch64-none-linux-gnu/aarch64-none-linux-gnu
FINDER_APP_PATH=/home/khaled/Desktop/Linux-system-programming/week2/assignments-3-and-later-kal997/finder-app

if [ $# -lt 1 ]
then
	echo "Using default directory ${OUTDIR} for output"
else
	OUTDIR=$1
	echo "Using passed directory ${OUTDIR} for output"
fi

if [ ! -d ${OUTDIR} ]; then
	mkdir -p "$OUTDIR"
	cd "$OUTDIR"
fi



if [ ! -d "${OUTDIR}/linux-stable" ]; then
    #Clone only if the repository does not exist.
	echo "CLONING GIT LINUX STABLE VERSION ${KERNEL_VERSION} IN ${OUTDIR}"
	
	cd ${OUTDIR}
	git clone ${KERNEL_REPO} --depth 1 --single-branch --branch ${KERNEL_VERSION}
	git clone ${PATCH_REPO}
fi



if [ ! -e ${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image ]; then
    cd ${OUTDIR}/linux-stable
    echo "***************"
    ls
    echo "***********"
    pwd
    echo "Checking out version ${KERNEL_VERSION}"
    git checkout ${KERNEL_VERSION}
	
	echo "applying patch"
	rm ${OUTDIR}/linux-stable/scripts/dtc/dtc-lexer.l
	cp ${OUTDIR}/linux-v5.1.10-patch/dtc-lexer.l ./scripts/dtc/dtc-lexer.l
    # TODO: Add your kernel build steps here
	echo "*******deep clean*********"
	make ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- mrproper
	
	echo "*******build defconfig*********"
	make ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- defconfig
	echo "*******build the kernel*********"
	make -j4 ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- all

	make ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- modules
	make ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- dtbs
	
	echo "Adding the Image in outdir"
	cp ${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image ${OUTDIR}/

	
fi



echo "Creating the staging directory for the root filesystem"
cd "$OUTDIR"
if [ -d "${OUTDIR}/rootfs" ]
then
	echo "Deleting rootfs directory at ${OUTDIR}/rootfs and starting over"
    sudo rm  -rf ${OUTDIR}/rootfs
fi


# TODO: Create necessary base directories
mkdir -p rootfs
cd ./rootfs
mkdir -p bin dev etc home lib lib64 proc sbin sys tmp usr var
mkdir -p usr/bin usr/lib usr/sbin




cd "$OUTDIR"
if [ ! -d "${OUTDIR}/busybox" ];
then
git clone git://busybox.net/busybox.git
    cd busybox
    git checkout ${BUSYBOX_VERSION}
    # TODO:  Configure busybox
    make distclean
    make defconfig

else
    cd busybox
    
fi


# TODO: Make and install busybox


make ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu-
make CONFIG_PREFIX=../rootfs/ ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- install







echo "Library dependencies"
pwd
${CROSS_COMPILE}readelf -a busybox | grep "program interpreter"
${CROSS_COMPILE}readelf -a busybox | grep "Shared library"

# TODO: Add library dependencies to rootfs
cp ${OUTDIR}/linux-v5.1.10-patch/libc.so.6 ${OUTDIR}/rootfs/lib64/
cp ${OUTDIR}/linux-v5.1.10-patch/libresolv.so.2 ${OUTDIR}/rootfs/lib64/
cp ${OUTDIR}/linux-v5.1.10-patch/libm.so.6 ${OUTDIR}/rootfs/lib64/

cp ${OUTDIR}/linux-v5.1.10-patch/ld-linux-aarch64.so.1 ${OUTDIR}/rootfs/lib/


# TODO: Make device nodes
cd ${OUTDIR}/rootfs/
echo "rootfs content******************"
ls
sudo mknod -m 666 dev/null c 1 3
sudo mknod -m 600 dev/console c 5 1
sudo mknod -m 666 dev/tty c 5 0 
sudo chown root:tty /dev/{console,ptmx,tty}

# TODO: Clean and build the writer utility
cd ${OUTDIR}/linux-v5.1.10-patch/
aarch64-none-linux-gnu-gcc -o writer writer.c 
cp writer ${OUTDIR}/rootfs/home/
cp new.txt ${OUTDIR}/rootfs/home/
cp finder.sh ${OUTDIR}/rootfs/home/
cp finder-test.sh ${OUTDIR}/rootfs/home/
cp -r conf/ ${OUTDIR}/rootfs/home/
cp autorun-qemu.sh ${OUTDIR}/rootfs/home/



# TODO: Copy the finder related scripts and executables to the /home directory
# on the target rootfs
cd ${OUTDIR}/rootfs
sudo chown -R root:root *
# TODO: Chown the root directory
cd ${OUTDIR}/rootfs/
ls
find . | cpio -H newc -ov --owner root:root > ../initramfs.cpio
cd ..
ls
# TODO: Create initramfs.cpio.gz
gzip -f initramfs.cpio

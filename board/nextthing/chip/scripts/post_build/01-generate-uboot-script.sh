#!/usr/bin/env bash
#
# The MIT License (MIT)
#
# Copyright (c) 2015 Next Thing Co.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#

# argument settings
NAND_ERASE_BB=true
DEBUG=true
VERBOSE=false

# parse arguments
TEMP=`getopt -o e,d,v: --long erase-bb,debug,verbose -n '01-generate-uboot-script.sh' -- "$@"`
eval set -- "$TEMP"

while true ; do
    case "$1" in
        -e|--erase-bb) NAND_ERASE_BB=true ; shift ;;
        -d|--debug) DEBUG=true ; shift ;;
        -v|--verbose) VERBOSE=true ; shift ;;
        --) shift ; break ;;
        *) echo "Internal error!" ; exit 1 ;;
    esac
done

# Include common shell utils
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${DIR}" ]]; then DIR="${PWD}"; fi
if [[ -f "${DIR}/../common.inc" ]]; then
  source "${DIR}/../common.inc"
else
  echo "Could not load common includes at ${BASH_SOURCE%/*}."
  echo "Exiting..."
  exit 1
fi


# get environment info
if [ -z "${TARGETDIR}" ]; then
  TARGETDIR=`pwd`
  PROJECT_ROOT="${TARGETDIR}"
else
  PROJECT_ROOT="${TARGETDIR}/../.."
fi

BUILDROOT_OUTPUT_DIR="${PROJECT_ROOT}/output"

# output if nand erase is enabled
if [ ${NAND_ERASE_BB} == true ]; then
  debug "NAND Erase enabled"
fi

# executables
MKIMAGE="output/host/usr/bin/mkimage"

# temporary data
TMPDIR=`mktemp -d`
PADDED_SPL="${TMPDIR}/sunxi-padded-spl"
UBOOT_SCRIPT="${TMPDIR}/uboot.scr"
UBOOT_SCRIPT_SRC="${TMPDIR}/uboot.cmds"
PADDED_UBOOT="${TMPDIR}/padded-uboot"

# buildroot output images
SPL="${BUILDROOT_OUTPUT_DIR}/images/sunxi-spl.bin"
UBOOT="${BUILDROOT_OUTPUT_DIR}/images/u-boot-dtb.bin"
UBI="${BUILDROOT_OUTPUT_DIR}/images/rootfs.ubi"

# global data
PADDED_SPL_SIZE=0
UBOOT_SCRIPT_MEM_ADDR=0x43100000
SPL_MEM_ADDR=0x43000000
PADDED_UBOOT_SIZE=0
UBOOT_MEM_ADDR=0x4a000000
UBI_MEM_ADDR=0x44000000

debug "Temporary Directory:   ${TMPDIR}"


# prepare images
marker "Prepare uboot images"
function prepare_images {
  local in=$1
  local out=$2

  if [ -e ${out} ]; then
    rm ${out}
  fi

  # The BROM cannot read 16K pages: it only reads 8k of data at most.
  # Split the SPL image in 8k chunks and pad each chunk with 8k of random
  # data to limit the impact of repeated patterns on the MLC chip.

  dd if=${in} of=${out} bs=8k count=1 skip=0 conv=sync &> /dev/null
  dd if=/dev/urandom of=${out} bs=8k count=1 seek=1 conv=sync &> /dev/null
  dd if=${in} of=${out} bs=8k count=1 skip=1 seek=2 conv=sync &> /dev/null
  dd if=/dev/urandom of=${out} bs=8k count=1 seek=3 conv=sync &> /dev/null
  dd if=${in} of=${out} bs=8k count=1 skip=2 seek=4 conv=sync &> /dev/null
  dd if=/dev/urandom of=${out} bs=8k count=1 seek=5 conv=sync &> /dev/null

  # Align the u-boot image on a page boundary
  dd if=${UBOOT} of=${PADDED_UBOOT} bs=16k conv=sync &> /dev/null
}
prepare_images ${SPL} ${PADDED_SPL}

# get size data and output
ORIGINAL_SPL_SIZE=`stat --printf="%s" ${SPL} | xargs printf "0x%08x"`
PADDED_SPL_SIZE=`stat --printf="%s" ${PADDED_SPL} | xargs printf "0x%08x"`
ORIGINAL_UBOOT_SIZE=`stat --printf="%s" ${UBOOT} | xargs printf "0x%08x"`
PADDED_UBOOT_SIZE=`stat --printf="%s" ${PADDED_UBOOT} | xargs printf "0x%08x"`

debug "Original spl size:     ${ORIGINAL_SPL_SIZE}"
debug "Padded spl size:       ${PADDED_SPL_SIZE}"
debug "Original uboot size:   ${ORIGINAL_UBOOT_SIZE}"
debug "Padded uboot size:     ${PADDED_UBOOT_SIZE}"


# prepare uboot script
marker "Making uboot script"
if [ "${NAND_ERASE_BB}" = true ] ; then
  echo "nand scrub -y 0x0 0x200000000" > ${UBOOT_SCRIPT_SRC}
else
  echo "nand erase 0x0 0x200000000" > ${UBOOT_SCRIPT_SRC}
fi

cat <<-END > ${UBOOT_SCRIPT_SRC}
  sunxi_nand config spl
  nand write ${SPL_MEM_ADDR} 0x0 ${PADDED_SPL_SIZE}
  nand write ${SPL_MEM_ADDR} 0x100000 ${PADDED_SPL_SIZE}
  nand write ${SPL_MEM_ADDR} 0x200000 ${PADDED_SPL_SIZE}
  nand write ${SPL_MEM_ADDR} 0x300000 ${PADDED_SPL_SIZE}
  nand write ${SPL_MEM_ADDR} 0x400000 ${PADDED_SPL_SIZE}
  nand write ${SPL_MEM_ADDR} 0x500000 ${PADDED_SPL_SIZE}
  nand write ${SPL_MEM_ADDR} 0x600000 ${PADDED_SPL_SIZE}
  nand write ${SPL_MEM_ADDR} 0x700000 ${PADDED_SPL_SIZE}
  sunxi_nand config default
  nand write ${UBOOT_MEM_ADDR} 0x800000 ${PADDED_UBOOT_SIZE}
  nand write.trimffs ${UBI_MEM_ADDR} 0x1000000 ${UBI_SIZE}
  setenv bootargs root=ubi0:rootfs rootfstype=ubifs rw earlyprintk ubi.mtd=4
  setenv bootcmd 'source \${scriptaddr}; mtdparts; ubi part UBI; ubifsmount ubi0:rootfs; ubifsload \${fdt_addr_r} /boot/sun5i-r8-chip.dtb; ubifsload \${kernel_addr_r} /boot/zImage; bootz \${kernel_addr_r} - \${fdt_addr_r}'
  saveenv
  mw \${scriptaddr} 0x0
  boot
END
cat ${UBOOT_SCRIPT_SRC}
$MKIMAGE -A arm -T script -C none -n "flash CHIP" -d ${UBOOT_SCRIPT_SRC} ${UBOOT_SCRIPT} &> /dev/null

cp ${PADDED_SPL} ${BUILDROOT_OUTPUT_DIR}/images
cp ${PADDED_UBOOT} ${BUILDROOT_OUTPUT_DIR}/images
cp ${UBOOT_SCRIPT} ${BUILDROOT_OUTPUT_DIR}/images
rm -rf $TMPDIR
##################################################################
#      DuetPkgPreBuild.sh     Copyright(C) 2018 Max Wu
#
# PreBuild of DuetPkg
#
##################################################################

#!/bin/bash

#
# EDK2 build environment setup
#
cd edk2
. ./edksetup.sh

#
# Build efi64.com2 from DuetPkg/bootSector
#
mkdir -p DuetPkg/BootSector/bin
OUTPUT_DIR=./bin MODULE_DIR=. make -C DuetPkg/BootSector/ -f GNUmakefile

#
# Build lddos.com
#
cd ..
make -C lddos -f Makefile

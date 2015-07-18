#!/bin/sh
# This program gets the power status (AC IN or BAT) for pcDuino3
# I2C interface with AXP209
#
#######################################################################
# Copyright (c) 2014 by RzBo, Bellesserre, France
#
# Permission is granted to use the source code within this
# file in whole or in part for any use, personal or commercial,
# without restriction or limitation.
#
# No warranties, either explicit or implied, are made as to the
# suitability of this code for any purpose. Use at your own risk.
#######################################################################

#read Power status register @00h
POWER_STATUS=$(i2cget -y -f 0 0x34 0x00)
#echo $POWER_STATUS

# bit 7 : Indicates ACIN presence 0: ACIN does not exist; 1: ACIN present
#echo "bit 7 : Indicates ACIN presence 0: ACIN does not exist; 1: ACIN present"
#echo "bit 2 : Indicates that the battery current direction 0: battery discharge; 1: The battery is charged"

AC_STATUS=$(($(($POWER_STATUS&0x80))/128))  # divide by 128 is like shifting rigth 8 times
#echo $(($POWER_STATUS&0x80))
echo "AC_STATUS="$AC_STATUS
# echo $AC_STATUS


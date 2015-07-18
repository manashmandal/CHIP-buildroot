#!/bin/bash

SCRIPT_DIR=${0%/*}
TARGET_DIR=$1

echo -e "\n-------------------------------------"
echo "adding hwtest"
echo "-------------------------------------"

install -m 0755 ${SCRIPT_DIR}/hwtest.sh ${TARGET_DIR}/usr/bin/hwtest.sh
install -m 0755 ${SCRIPT_DIR}/battery.sh ${TARGET_DIR}/usr/bin/battery.sh
install -m 0755 ${SCRIPT_DIR}/power.sh ${TARGET_DIR}/usr/bin/power.sh


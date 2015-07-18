#!/bin/bash

SCRIPT_DIR=${0%/*}
TARGET_DIR=$1

echo -e "\n-------------------------------------"
echo "adding hwtest"
echo "-------------------------------------"

install -m 0755 ${SCRIPT_DIR}/hwtest.sh ${TARGET_DIR}/usr/bin/hwtest.sh
install -m 0755 ${SCRIPT_DIR}/battery.sh ${TARGET_DIR}/usr/bin/battery.sh
install -m 0755 ${SCRIPT_DIR}/power.sh ${TARGET_DIR}/usr/bin/power.sh

echo -e "\\n
          MM      MMM      MM.          \n\
          MM      MMM     .MM           \n\
          MM      MMM      MM.          \n\
     MMMMMMMMMMMMMMMMMMMMMMMMMMMMM      \n\
    .MM                         MM.     \n\
    .MM                        .MM.     \n\
MMMMMMM                        .MMMMMMM \n\
MMMMMMM      MMMM              .MMMMMMM \n\
    .MM     MMMMMM.            .MM.     \n\
    .MM    8MMMMMM,            .MM.     \n\
    .MM     MMMMMMMM.          .MM.     \n\
MMMMMMM     .....MMMMMMMMMMMMMMMMMMMMMN \n\
MMMMMMM             .:MMMMMMMMMMMMMMMMM.\n\
    .MM                        .MM.     \n\
    .MM                        .MM.     \n\
    .MM                        .MM.     \n\
8MMMMMM       Next Thing Co    .MMMMMMO \n\
MMMMMMM                        .MMMMMMM:\n\
.    MM                        .MM      \n\
    .MM                        .MM.     \n\
    .MMMMMMMMMMMMMMMMMMMMMMMMMMMMM      \n\
          MM      MMM     .MM           \n\
          MM      MMM     .MM           \n\
          MM      MMM     .MM           \n\
          .Z       M      .O            \n\
\n\
" > ${TARGET_DIR}=/etc/issue

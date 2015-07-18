#/bin/sh

echo -e "\n-- C.H.I.P Hardware test --\n"

echo -e "\n * Hardware List:"
lshw

echo -e "\n * I2C bus 0:"
i2cdetect -y 0
echo -e "\n * I2C bus 1:"
i2cdetect -y 1
echo -e "\n * I2C bus 2:"
i2cdetect -y 2

echo -e "\n * testing AXP209 on I2C bus 0:"
battery.sh
power.sh

echo -e "\n * testing NAND write speed 1K block size"
dd if=/dev/zero of=/NAND_write_speed bs=1k count=256k
echo -e "\n * testing NAND write speed 16K block size"
dd if=/dev/zero of=/NAND_write_speed bs=16k count=16k

if [[ -b /dev/sda ]];
then
  echo -e "\n * USB device /dev/sda found - type yes to *DESTROY* it's contents"
  read confirmation
  if [[ "${confirmation}" == "yes" ]]; 
  then
    echo -e "\n * testing USB write speed 1K block size"
    dd if=/dev/zero of=/dev/sda bs=1k count=256k
    echo -e "\n * testing USB write speed 4K block size"
    dd if=/dev/zero of=/dev/sda bs=4k count=64k
  fi
fi

echo -e "\n * Doing 10s stress test:"
stress -v --cpu 8 --io 4 --vm 2 --vm-bytes 128M --timeout 10s

echo -e "\n * Memory test (takes a while):"
tinymembench

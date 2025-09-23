#!/bin/bash

## SOURCE DOCUMENT -- https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/recognize-expanded-volume-linux.html ##

echo -e "[*] - Checking File Systems..."

echo -e "[*] - Get the root / partition..."
get_root_part=`df -h | grep mapper | grep root | awk '{print$1}'`

echo -e "[*] - Get total disk size..."
get_total=`lsblk | grep xvda2 | awk '{print$4}' | tr -dc '0-9'`

declare -a GET_PART_SIZE=(`lsblk | grep cl- | grep G | awk '{print$4}' | sed -e 's/[^0-9]*//g' `)

total=0
for i in ${GET_PART_SIZE[@]}; do
	let total+=$i
done
echo -e "[*] - Total Partition Size: $total GB"

get_allocated_space=`expr $((get_total-total-1))`

echo -e "[*] - Allocated Space: $get_allocated_space GB"

echo -e "[*] - Installing XFS tools...\n"
yum install -y xfsprogs

echo -e "\n[*] - Extending Volume $get_root_part to $get_allocated_space GB...\n"
lvextend -r -L +"$get_allocated_space"G "$get_root_part"

lsblk


# sudo yum install cloud-utils-growpart -y
# sudo growpart /dev/xvda 2
# sudo pvresize /dev/xvda2
# sudo lvextend -r -L +10G /dev/mapper/cl-docker
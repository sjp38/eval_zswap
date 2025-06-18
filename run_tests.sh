#!/bin/bash

echo "no memory pressure"
sudo ./run.sh ../masim /sys/fs/cgroup/ 3G N 1 none none none 120

echo "zswap disabled"
sudo ./run.sh ../masim /sys/fs/cgroup/ 2G N 1 none none none 120

echo
echo "zswap disabled, cold data is incompressbile"
sudo ./run.sh ../masim /sys/fs/cgroup/ 2G N 1 none none /dev/urandom 120

echo
echo "zswap enabled"
sudo ./run.sh ../masim /sys/fs/cgroup/ 2G Y 1 none none none 120

echo
echo "zswap enabled, cold data is incompressbile"
sudo ./run.sh ../masim /sys/fs/cgroup/ 2G Y 1 none none /dev/urandom 120

echo
echo "zswap enabled, writeback disabled"
sudo ./run.sh ../masim /sys/fs/cgroup/ 2G Y 0 none none none 120

echo
echo "zswap enabled, writeback disabled, cold data is incompressbile"
sudo ./run.sh ../masim /sys/fs/cgroup/ 2G Y 1 none none /dev/urandom 120

#!/bin/bash

log_dir="logs/$(date +%Y-%m-%d-%H-%M-%S)"
mkdir -p "$log_dir"

echo "no memory pressure"
sudo ./run.sh ../masim /sys/fs/cgroup/ 3G N 1 none none none 120 | tee "$log_dir/0"

echo "zswap disabled"
sudo ./run.sh ../masim /sys/fs/cgroup/ 2G N 1 none none none 120 | tee "$log_dir/1-1"

echo
echo "zswap disabled, cold data is incompressbile"
sudo ./run.sh ../masim /sys/fs/cgroup/ 2G N 1 none none /dev/urandom 120 | tee "$log_dir/1-2"

echo
echo "zswap enabled"
sudo ./run.sh ../masim /sys/fs/cgroup/ 2G Y 1 none none none 120 | tee "$log_dir/2-1"

echo
echo "zswap enabled, cold data is incompressbile"
sudo ./run.sh ../masim /sys/fs/cgroup/ 2G Y 1 none none /dev/urandom 120 | tee "$log_dir/2-2"

echo
echo "zswap enabled, writeback disabled"
sudo ./run.sh ../masim /sys/fs/cgroup/ 2G Y 0 none none none 120 | tee "$log_dir/3-1"

echo
echo "zswap enabled, writeback disabled, cold data is incompressbile"
sudo ./run.sh ../masim /sys/fs/cgroup/ 2G Y 1 none none /dev/urandom 120 | tee "$log_dir/3-2"

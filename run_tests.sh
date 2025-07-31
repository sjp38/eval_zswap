#!/bin/bash

if [ $# -eq 1 ]
then
	log_dir=$1
else
	log_dir=logs
fi

log_dir="${log_dir}/$(date +%Y-%m-%d-%H-%M-%S)"
mkdir -p "$log_dir"

echo "no memory pressure"
sudo ./run.sh ../masim /sys/fs/cgroup/ 2G N N N \
	./compressible_data ./compressible_data /dev/urandom 120 | \
	tee "$log_dir/0"

echo
echo "zswap disabled, 10 % memory pressure"
sudo ./run.sh ../masim /sys/fs/cgroup/ 1350M N N N \
	./compressible_data ./compressible_data /dev/urandom 120 | \
	tee "$log_dir/1-1"

echo
echo "zswap enabled, 10 % memory pressure"
sudo ./run.sh ../masim /sys/fs/cgroup/ 1350M Y N N \
	./compressible_data ./compressible_data /dev/urandom 120 | \
	tee "$log_dir/1-2"

echo
echo "zswap enabled with keeping incompressible pages, 10 % memory pressure"
sudo ./run.sh ../masim /sys/fs/cgroup/ 1350M Y N Y \
	./compressible_data ./compressible_data /dev/urandom 120 | \
	tee "$log_dir/1-3"

echo
echo "zswap disabled, 20 % memory pressure"
sudo ./run.sh ../masim /sys/fs/cgroup/ 1200M N N N \
	./compressible_data ./compressible_data /dev/urandom 120 | \
	tee "$log_dir/2-1"

echo
echo "zswap enabled, 20 % memory pressure"
sudo ./run.sh ../masim /sys/fs/cgroup/ 1200M Y N N \
	./compressible_data ./compressible_data /dev/urandom 120 | \
	tee "$log_dir/2-2"

echo
echo "zswap enabled with keeping incompressible pages, 20 % memory pressure"
sudo ./run.sh ../masim /sys/fs/cgroup/ 1200M Y N Y \
	./compressible_data ./compressible_data /dev/urandom 120 | \
	tee "$log_dir/2-3"

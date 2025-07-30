#!/bin/bash

set -e

if [ $# -ne 9 ]
then
	echo "Usage: $0 <masim dir> <cgroup mount path> <mem.high> <zswap enable> <save incompressbile pages> <hot data> <warm data> <cold data> <runtime_seconds>"
	echo "e.g., $0 ../masim/ /sys/fs/cgroup/ 2G Y 0 none none /dev/urandom 60"
	exit 1
fi

if [ "$EUID" -ne 0 ]
then
	echo "Run as root"
	exit 1
fi

bindir=$(dirname "$0")
masim_dir=$1
cgroup_dir="${2}/eval_zswap"
mem_high=$3
zswap_enabled=$4
zswap_save_incompressible_pages=$5
first_data=$6
second_data=$7
third_data=$8
runtime_seconds=$9

echo N > /sys/module/zswap/parameters/enabled
swapoff -a
swapon /dev/vda5
echo 3 > /proc/sys/vm/drop_caches

mkdir "$cgroup_dir"
echo $$ > "${cgroup_dir}/cgroup.procs"
echo "$mem_high" > "${cgroup_dir}/memory.high"

echo "$zswap_enabled" > "/sys/module/zswap/parameters/enabled"
echo "$zswap_save_incompressible_pages" > "/sys/module/zswap/parameters/save_incompressible_pages"

"$bindir/stat.py" > before_masim

"${masim_dir}/masim.py" run --masim_bin "${masim_dir}/masim" \
	--phase one $((runtime_seconds * 1000)) \
	--region first 500M "$first_data" --region second 500M "$second_data" \
	--region third 500M "$third_data" \
	--access_pattern one first 1 4k 100 rw \
	--access_pattern one second 1 4k 100 rw \
	--access_pattern one third 1 4k 100 rw \
	--log_interval 5000 \
	--accesses_per_region_selection 1

"$bindir/stat.py" --before_output before_masim
echo $$ > "${cgroup_dir}/../cgroup.procs"
rmdir "$cgroup_dir"

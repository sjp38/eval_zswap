#!/bin/bash

set -e

if [ $# -ne 9 ]
then
	echo "Usage: $0 <masim dir> <cgroup mount path> <mem.high> <zswap enable> <zswap writeback> <hot data> <warm data> <cold data> <runtime_seconds>"
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
zswap_writeback=$5
hot_data=$6
warm_data=$7
cold_data=$8
runtime_seconds=$9

mkdir "$cgroup_dir"
echo $$ > "${cgroup_dir}/cgroup.procs"
echo "$mem_high" > "${cgroup_dir}/memory.high"

echo "$zswap_enabled" > "/sys/module/zswap/parameters/enabled"
echo "$zswap_writeback" > "${cgroup_dir}/memory.zswap.writeback"

echo 3 > /proc/sys/vm/drop_caches

"$bindir/stat.py" > before_masim

"${masim_dir}/masim.py" run --masim_bin "${masim_dir}/masim" \
	--phase one $((runtime_seconds * 1000)) \
	--region hot 1G "$hot_data" --region warm 1G "$warm_data" \
	--region cold 100M "$cold_data" \
	--access_pattern one hot 1 4k 70 rw \
	--access_pattern one warm 1 4k 20 rw \
	--access_pattern one cold 1 4k 10 rw \
	--log_interval 5000 \
	--accesses_per_region_selection 1

"$bindir/stat.py" --before_output before_masim
echo $$ > "${cgroup_dir}/../cgroup.procs"
rmdir "$cgroup_dir"

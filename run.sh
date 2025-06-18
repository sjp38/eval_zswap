#!/bin/bash

set -e

if [ $# -ne 8 ]
then
	echo "Usage: $0 <masim dir> <cgroup mount path> <zswap enable> <zswap writeback> <hot data> <warm data> <cold data> <runtime_seconds>"
	echo "e.g., $0 ../masim/ /sys/fs/cgroup/ Y 0 none none /dev/urandom 60"
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
zswap_enabled=$3
zswap_writeback=$4
hot_data=$5
warm_data=$6
cold_data=$7
runtime_seconds=$8

mkdir "$cgroup_dir"
echo $$ > "${cgroup_dir}/cgroup.procs"
echo 2G > "${cgroup_dir}/memory.high"

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
	--log_interval 5000

"$bindir/stat.py" --before_output before_masim
echo $$ > "${cgroup_dir}/../cgroup.procs"
rmdir "$cgroup_dir"

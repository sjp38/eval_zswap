#!/bin/bash

if [ $# -ne 2 ]
then
	echo "Usage: $0 <logs dir> <data points per log>"
	echo "e.g., $0 logs/2025-07-22-15-12-52/ 10"
	exit 1
fi

logsdir=$1
tail_length=$2
statof_py="../lazybox/scripts/report/statof.py"

for f in "$logsdir"/*
do
	file_name=$(basename "$f")
	avg_perf=$(cat "$f" | grep msec | tail -n "$tail_length" | \
		awk '{print $2}' | sed 's/,//g' | "$statof_py" avg stdin)
	stdev=$(cat "$f" | grep msec | tail -n "$tail_length" | \
		awk '{print $2}' | sed 's/,//g' | "$statof_py" stdev stdin)
	echo "$file_name"
	echo "perf: $avg_perf"
	echo "perf_stdev: $stdev"
	for field in zswpin zswpout zswpwb pswpin pswpout
	do
		grep "$field" $f
	done
	echo
done

#!/usr/bin/env python3

import argparse
import os
import json

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--before_output', metavar='<file>',
                        help='before_output')
    args = parser.parse_args()

    stats = {}
    for stat in ['reject_compress_fail', 'reject_compress_poor',
                 'stored_pages', 'written_back_pages']:
        filepath = os.path.join('/sys/kernel/debug/zswap', stat)
        if not os.path.isfile(filepath):
            stats[stat] = 0
            continue
        with open(filepath, 'r') as f:
            stats[stat] = int(f.read())
    with open('/proc/vmstat', 'r') as f:
        for line in f:
            stat, val = line.split()
            if stat in ['pswpin', 'pswpout', 'zswpin', 'zswpout', 'zswpwb']:
                stats[stat] = int(val)
    if args.before_output is None:
        print(json.dumps(stats, indent=4))
        return

    with open(args.before_output, 'r') as f:
        before_stat = json.load(f)
    for stat in before_stat:
        print('%s: %d' % (stat, stats[stat] - before_stat[stat]))

if __name__ == '__main__':
    main()

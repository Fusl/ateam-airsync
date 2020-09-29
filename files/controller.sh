#!/bin/bash

test -d /data || {
	echo 'No /data mount found'
	exit 1
}

mkdir -p /data/incoming

chown nobody:nobody /data/incoming

rsync_stopped=1

supervisorctl stop rsyncd

cleanup_temp() {
	find /data/incoming/ -type f '(' -wholename '*/.rsync-tmp/*' -o -name '*.warc.gz.*' -o -name '*.warc.zst.*' ')' -delete
	find /data/incoming/ -mindepth 1 -type d -empty -delete
}

cleanup_temp

while true; do
	disk_usage=$(df --output=pcent /data/ | tr -dc '0-9')
	echo "disk_usage=${disk_usage}/${DISK_LIMIT:-60}/${DISK_HARD_LIMIT:-85}"
	if test -z "${disk_usage}"; then
		echo 'killing rsyncd'
		supervisorctl stop rsyncd && rsync_stopped=1
		pkill -9 -f '^/usr/bin/rsync '
		echo '/data is not a volume'
		sleep 5
		continue
	fi
	if test "${disk_usage}" -gt "${DISK_HARD_LIMIT:-85}"; then
		if test -z "${rsync_stopped}"; then
			echo 'killing rsyncd'
			supervisorctl stop rsyncd && rsync_stopped=1
			pkill -9 -f '^/usr/bin/rsync '
			cleanup_temp
		fi
		sleep 5
		continue
	elif test "${disk_usage}" -gt "${DISK_LIMIT:-60}"; then
		tgt_conn=-1
	else
		tgt_conn="${MAX_CONN:-100}"
	fi
	cat /rsyncd.conf | sed "s|{{tgt_conn}}|${tgt_conn}|g" > /tmp/rsyncd.conf.new && mv /tmp/rsyncd.conf.new /tmp/rsyncd.conf
	if test -n "${rsync_stopped}"; then
		cleanup_temp
		supervisorctl start rsyncd && rsync_stopped=
	fi
	if test "${tgt_conn}" == '-1' && test -z "${rsync_stopped}"; then
		sleep 0.5
	else
		sleep 1
	fi
done

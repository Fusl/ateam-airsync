#!/bin/bash

test -d /data || {
	echo "No /data mount found"
	exit 1
}

mkdir -p /data/incoming

chown nobody:nobody /data/incoming

rsync_stopped=1

supervisorctl stop rsyncd

while true; do
	disk_usage=$(df --output=pcent /data/ | tr -dc '0-9')
	if test -z "${disk_usage}"; then
		supervisorctl stop rsyncd && rsync_stopped=1
		echo "/data is not a volume"
		sleep 5
		continue
	fi
	if test "${disk_usage}" -gt 60; then
		supervisorctl stop rsyncd && rsync_stopped=1
		sleep 5
		continue
	elif test "${disk_usage}" -gt 50; then
		tgt_conn=-1
	else
		tgt_conn=${MAX_CONN:-100}
	fi
	cat /rsyncd.conf | sed "s|{{tgt_conn}}|${tgt_conn}|g" > /tmp/rsyncd.conf.new && mv /tmp/rsyncd.conf.new /tmp/rsyncd.conf
	if test -n "${rsync_stopped}"; then
		find /data/incoming/ -type f -wholename "*/.rsync-tmp/*" -delete
		supervisorctl start rsyncd && rsync_stopped=
	fi
	sleep 5
done

#!/bin/bash
set -e

secrets_file="${1:-/rsyncd.secrets}"
runtime_secrets="${2:-/tmp/rsyncd.secrets}"

# missing or empty credentials -> no auth
if [[ ! -e "$secrets_file" ]]; then
	exit 0
fi

if [[ ! -f "$secrets_file" ]]; then
    echo "Invalid rsync secrets file: '$secrets_file' is not a file" >&2
    exit 1
fi

auth_users=
while IFS= read -r line || [[ -n "$line" ]]; do
  # skip empty lines and comments (starting with #)
	if [[ -z "$line" || "$line" =~ ^# ]]; then
		continue
	fi
	# line needs to be user:password
	if [[ "$line" != *:* ]]; then
		echo "Invalid rsync secrets file: expected username:password entries, but got '$line'" >&2
		exit 1
	fi

	username=${line%%:*}
	if [[ -z "$username" ]]; then
		echo 'Invalid rsync secrets file: empty username' >&2
		exit 1
	fi

	if [[ -n "$auth_users" ]]; then
		auth_users+=,
	fi
	auth_users+=$username
done < "$secrets_file"

# no users = don't emit anything
[[ -n "$auth_users" ]] || exit 0

# the provided secrets file may have permissions that fail rsync's strict mode check, so make a private copy
install -m 600 "$secrets_file" "$runtime_secrets"
printf 'auth users = %s\nsecrets file = %s\n' "$auth_users" "$runtime_secrets"

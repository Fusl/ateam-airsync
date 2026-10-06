# ateam-airsync
Archive Team dockerized rsync target

## Usage
Use with Docker:

```zsh
docker run -e "MAX_CONN=18" -e "PORT=873" -e "DISK_LIMIT=50" -e "DISK_HARD_LIMIT=80" --rm --name archiveteam_target -v archiveteam_target_data:/data -p 873:873 \
  atdr.meo.ws/fusl/ateam-airsync
```

(Obviously change the `-e` options to what you'd like. The DISK_LIMIT and DISK_HARD_LIMIT variables are percentages.
If DISK_LIMIT is reached, it will stop accepting connections; if the hard limit is reached, it'll kill all connections,
including existing ones. PORT is the port. And MAX_CONN is maximum number of simultaneous connections.)

With that command, data will be stored in the `archiveteam_target_data` Docker volume.

### Authentication
To require authentication for uploads, mount a secrets file with one `username:password` entry per line to `/rsyncd.secrets`.  Blank lines and lines starting with `#` are ignored.

For example:
```
# a user with a password
user1:password1
# another entry!
user2:mypassword123
```

```zsh
docker run -e "MAX_CONN=18" -e "PORT=873" -e "DISK_LIMIT=50" -e "DISK_HARD_LIMIT=80" --rm --name archiveteam_target -v archiveteam_target_data:/data -p 873:873 \
  -v /path/to/rsyncd.secrets:/rsyncd.secrets:ro \
  atdr.meo.ws/fusl/ateam-airsync
```

Clients can upload with:
```sh
RSYNC_PASSWORD=mypassword rsync -rltv /path/to/files/ rsync://myuser@host:873/ateam-airsync/
```
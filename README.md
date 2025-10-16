### Docker

Mount the ceph-fs diretly in the container

```bash
# Create storage path
cd /mnt/pve/cephfs/
mkdir docker
pct set 100 -mp0 /mnt/pve/cephfs/docker,mp=/mnt/docker,shared=1

# Check permissions
ls -ld /mnt/pve/cephfs/docker
ls -ld /mnt/pve/cephfs/docker/syncthing/config

# Set proper permissions
chown -R 100911:100911 /mnt/pve/cephfs/docker/syncthing/kotick
chown -R 100911:100911 /mnt/pve/cephfs/docker/syncthing/serverplus

chmod -R u+rwx /mnt/pve/cephfs/docker/syncthing/kotick
chmod -R u+rwx /mnt/pve/cephfs/docker/syncthing/serverplus
```

### Folder structure

config
kotick
serverplus

root@docker:/mnt/docker/syncthing

syncthing/kotick
syncthing/serverplus
syncthing/config

timemachine/rox/config
timemachine/rox/storage
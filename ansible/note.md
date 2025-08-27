This is a sample repo to test ansible-pull on ucore

fstab
networking
ssh
firewalld
tailscale
snapraid
podman socket
nfs
samba
mergerfs
selinux
power
btrfs scrubs
health check


echo zfs > /etc/modules-load.d/zfs.conf

# Substitute <pool> with the name of the zpool
systemctl enable --now zfs-scrub-weekly@<pool>.timer

# Or to run it monthly:
systemctl enable --now zfs-scrub-monthly@<pool>.timer

enable cockpit.service



ansible -i inventory/hosts.yml core2 -m ping -k -K
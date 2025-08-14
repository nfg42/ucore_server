# ucore_server

[![Wiki](https://img.shields.io/badge/Docs-Wiki-blue)](https://github.com/nfg42/ucore_server/wiki)


[![uCore Base](https://img.shields.io/badge/Base-uCore-orange)](https://github.com/ublue-os/ucore)
[![Build Status](https://img.shields.io/badge/Build-bootc-green)](#)
[![Podman](https://img.shields.io/badge/Container%20Runtime-Podman-purple)](https://podman.io/)
[![Build Status](https://github.com/nfg42/ucore_server/actions/workflows/build.yml/badge.svg?branch=main)](https://github.com/nfg42/ucore_server/actions/workflows/build.yml)


> ⚠ **Warning:** ucore_server is **incomplete and under active development**.  
> Features and configurations may change at any time. Do not use in production without backups.

[![Try it Now](https://img.shields.io/badge/Try%20it%20Now-Quick%20Start-brightgreen)](https://github.com/nfg42/ucore_server/wiki/Quick-Start)

---

**A modern home server OS without the bloat.**  
Built on [uBlue's uCore](https://universal-blue.org/ucore/), powered by **Podman**, **systemd**, and **Ansible**, with **Cockpit** for effortless management.  
Runs great on used business PCs and is designed to be simple, maintainable, and self-documenting.

---

## 🚀 Why ucore_server?

Most home server platforms lock you into *their* way of doing things.  
`ucore_server` is different:

- **Lightweight** — minimal host OS, everything else runs in containers.
- **Standard Linux tools** — Podman, systemd, and Ansible. No proprietary daemons or custom web frameworks.
- **Immutable base** — updates are atomic and rollbacks are instant with `bootc`.
- **Self-documenting configuration** — your entire setup lives in an Ansible repo.
- **Host-managed storage** — no passing disks into a VM just to use them.

---

## 🔍 Why not just use…?

| Platform        | Why choose **ucore_server** instead? |
|-----------------|--------------------------------------|
| **FreeNAS / TrueNAS** | **ZFS storage–first** — great for pure NAS, but not designed around bulk JBOD media storage with mixed drive sizes. Containers/apps usually run in a VM or jail, adding overhead. |
| **TrueNAS SCALE** | Better app ecosystem than CORE, but still ZFS-first and heavier than needed for a simple container-hosted home server. |
| **Proxmox**     | **VM/LXC–first** — bulk shared storage must be layered on top. Extra complexity if you just want containers and direct host storage. |
| **Unraid**      | **Locked down** proprietary core, no native ZFS. License fee required for larger drive counts. |
| **OpenMediaVault** | **No native ZFS**, and its plugin model can lag behind upstream releases. |
| **Synology / QNAP** | **Proprietary hardware & OS** — locked ecosystem, limited filesystem choices, costly hardware upgrades. |
| **Turnkey “homelab in a box” distros** | Often opinionated and less flexible — hard to swap or mix components without breaking the stack. |
| **Traditional Linux (Debian, Ubuntu, etc.)** | Fully flexible but **not immutable**, making it harder to reproduce or roll back cleanly. Updates can drift configurations over time, and container integration isn’t as tightly baked-in. |

---

## 🌟 Key Benefits

- **Container-first design** — every service runs as an OCI container with systemd quadlets.
- **Flexible storage** — Btrfs, MergerFS, SnapRAID, optional SSD write cache, ZFS for important data.
- **Web & CLI management** — Cockpit for quick tasks, Ansible for full automation.
- **Hardware-friendly** — runs great on second-hand business desktops or servers.
- **Fast recovery** — roll back OS updates instantly, restore data from snapshots/parity.
- **Network ready** — VLANs, macvlan/ipvlan for containers that need direct L2 access.

---

## 🛠 Example Uses

- Host your media library (Plex, Jellyfin, Emby) with parity-protected bulk storage.
- Run self-hosted apps (Nextcloud, Immich, Paperless) without a VM stack.
- Serve as your home lab container platform.
- Automate backups with Btrfs/ZFS snapshots.
- Provide isolated VLAN environments for sensitive services.

---

## 🏁 Getting Started

1. Install **uCore** on your hardware.
2. Switch to this image
3. Clone the `ucore_server` repository.
4. Configure your server via Ansible.
5. Access Cockpit to monitor and manage.

> Detailed installation guides are available in the [Wiki](./wiki).

---

## 🤝 Contribute

Got an idea for a service, role, or improvement?  
Open an issue or submit a PR — contributions are welcome!

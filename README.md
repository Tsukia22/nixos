# Our NixOS Setup & Usage Guide
## Installation & Setup
### First-Time Setup
1.  **Have NixOS installed**
- Use the official NixOS ISO (graphical or minimal).
- Follow the standard installation steps or install directly using a flake.
2.  **Create your own system under `/hosts`**
- Add a new directory for your system:
```
/hosts/desktop/<your-pc-name>
```
3.  **Add your system to `flake.nix`**
- Register your host entry in the flake configuration.
- This defines your hostname, role, and system settings.
4.  **Rebuild your system**
```bash
sudo  nixos-rebuild  switch  --flake  .#<hostname>
```
## First Run
### After Install
* Podman setup // kami in homefolder docker-compose up -d
* Traefik first time setup : ro
* Traefik labels explained
* Local ports & future external ports
* Dockge login (default: `25560`)
---
## Docker & Storage Guidelines
### Naming Conventions
* Docker stack naming
* Docker volume naming
### Volume Handling
* Exposing volumes
* Making volumes persistent
### SFTPGo
* Adding volumes
* Configuration notes
---
## Exposing Services to the Internet
### Cloudflare Setup
* DNS configuration
* Security considerations
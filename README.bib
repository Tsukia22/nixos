# How to get NixOS (with a git repo of a nix flake configuration) running on your machine.
# This guide was created from recent memory, so it could contain some errors.

# 1. Download the minimal install NixOS ISO and create a bootable USB.

# 2. Insert the USB into the computer and boot into the USB partition.

# 3. Once booted into the tty, check your disks using:
lsblk
# Example output:
# NAME        MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
# sda           8:0    1 28,6G  0 disk
# └─sda1        8:1    1 28,6G  0 part
# nvme0n1     259:0    0  3,7T  0 disk
# ├─nvme0n1p1 259:1    0  3,7T  0 part /nix/store
# │                                    /
# └─nvme0n1p2 259:2    0  511M  0 part /boot

# You probably need to put sudo in front of all the following commands.

# 4. If there is still an old filesystem on the disk it can help to start a clean partition table.
# nvme0n1 should reflect the disk from the result of lsblk, change it accordingly!
wipefs -a /dev/nvme0n1

# 5. Partition the disk
parted /dev/nvme0n1 -- mklabel gpt
parted /dev/nvme0n1 -- mkpart primary 512MiB 100%
parted /dev/nvme0n1 -- mkpart ESP fat32 1MiB 512MiB
parted /dev/nvme0n1 -- set 2 esp on

# 6. Format the partitions
mkfs.ext4 /dev/nvme0n1p1
mkfs.fat -F 32 /dev/nvme0n1p2

# 7. Mount filesystems
mount /dev/nvme0n1p1 /mnt
mkdir -p /mnt/boot
mount /dev/nvme0n1p2 /mnt/boot

# 8. Generate the configs
nixos-generate-config --root /mnt

# (I am not actually sure if this step is necessary...)
# 9. Edit the configuration.nix
nano /mnt/etc/nixos/configuration.nix

# Make sure the following settings are set in the configuration.
# (Replace hostname, timezone and username)
# {
#    boot.loader.systemd-boot.enable = true;
#    boot.loader.efi.canTouchEfiVariables = true;
#    networking.hostName = "HOSTNAME";
#    time.timeZone = "TIMEZONE";
#    services.openssh.enable = true;
#    users.users.USERNAME = {
#      isNormalUser = true;
#      extraGroups = [ "wheel" ];
#    };
# }

# I assume the computer has a wired connection, if it doesnt you will need to use iwctl.

# 10. Install NixOS
nixos-install

# 11. Reboot
reboot

# You can continue locally or switch to SSH.

# If you included git in the packages in configuration.nix, you can skip this step.
# 12. Downloads and temporarily enable git
nix-shell -p git

# Optional: I switched to an user home folder when doing this.
cd /home/USERNAME

# 13. Clone your desired configuration from git such as:
# (Use the HTTPS variant if you dont want to authenticate for a public repo)
git clone "https://github.com/Tsukia22/nixos.git"

# 14. Enter the repo directory (in my case: nixos)
cd nixos

# 15. Run this command to build nixos with the provided repo and hostname (in my case #xan01)
sudo nixos-rebuild switch --impure --flake .#xan01

# Enjoy
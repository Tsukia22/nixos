
# nixos git pull & rebuild
alias npr='cd /root/nixos; git pull; nixos-rebuild switch --impure --flake /root/nixos#$HOSTNAME'

# podman ps -a (small cli friendly version)
alias psa='podman ps -a --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}"'

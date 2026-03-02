To use the codeserver with containers

Expose the docker.sock in the compose file

`- /var/run/user/2001/podman/podman.sock:/var/run/user/1000/podman/podman.sock`

Install podman pip3 podman-compose

```
sudo su
apt-get update
apt-get install -y podman python3-pip
pip3 install podman-compose
```

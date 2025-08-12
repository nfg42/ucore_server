sudo podman build -t local-ublue ./
sudo podman image list
sudo bootc switch --transport containers-storage localhost/local-ublue
sudo reboot

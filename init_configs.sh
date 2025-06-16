export OC_CLIENT="4.16.35"
dnf update -y
# install python and cockpit (for VM console later)
dnf -y install python3.9 cockpit cockpit-machines
dnf -y install python-pip
systemctl enable --now cockpit.socket
###################
# Step#1b: Creating and mounting Disk Partitiions:
###################
parted -s -a optimal /dev/nvme0n1 mklabel gpt mkpart primary 0 900GB # used to be 3841GB
sleep 20
udevadm settle
parted -s -a optimal /dev/nvme1n1 mklabel gpt mkpart primary 0 900GB 
sleep 20
udevadm settle
mkfs.xfs /dev/nvme0n1p1
mkfs.xfs /dev/nvme1n1p1
X=`lsblk  /dev/nvme0n1p1 -no UUID`
echo "UUID=$X       /var/lib/containers/storage/   xfs     auto 0       0" >> /etc/fstab
sleep 20
Y=`lsblk  /dev/nvme1n1p1 -no UUID`
echo "UUID=$Y       /var/lib/libvirt   xfs     auto 0       0" >> /etc/fstab
mkdir -p /var/lib/containers/storage/
mkdir -p /var/lib/libvirt/
systemctl daemon-reload
mount -av
restorecon -rF /var/lib/containers/storage/
restorecon -rF /var/lib/libvirt/
sleep 20
###################
# Step#2a: Enable Virtualization:
###################
# enable virtualization: 
dnf -y install libvirt libvirt-daemon-driver-qemu qemu-kvm
usermod -aG qemu,libvirt $(id -un)
newgrp libvirt
logger "Finishing 2a"
sleep 30
systemctl enable libvirtd --now
logger "done with 2a"
###################
# Step#2b: set up SSH:
###################
ssh-keygen -t rsa -b 4096 -N '' -f ~/.ssh/id_rsa
sleep 10
#############
###################
# Step#2c: Install KCLI Tool to manage virtual environment
###################
dnf -y copr enable karmab/kcli
dnf -y install kcli bash-completion vim jq tar git ipcalc python3-pip
###################
# Step#2d: Virtual Machine images default location
###################
kcli create pool -p /var/lib/libvirt/images default
logger "Done with 2d"
###################
# Step#2e: Install other tools:
###################
dnf -y install podman httpd-tools runc wget nmstate containernetworking-plugins bind-utils bash-completion tree
###################
# Step#2f: Restart libvirt:
###################
systemctl restart libvirtd
###################
# Step#2g: Enable KShushy, to use Redfish API for VM management:
###################
pip3 install cherrypy 
pip install -U pip setuptools 
pip install pyopenssl
kcli create sushy-service --ssl --port 9000 
systemctl enable ksushy --now
sleep 10
###################
# Step#2h: Install OC Client & Mirror Plugin
###################
wget https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/$OC_CLIENT/openshift-client-linux-$OC_CLIENT.tar.gz
tar -xvf openshift-client-linux-$OC_CLIENT.tar.gz
mv oc /usr/bin/
rm -f openshift-client-linux-$OC_CLIENT.tar.gz
oc completion bash > oc.bash_completion
mv oc.bash_completion /etc/bash_completion.d/
#
curl https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/$OC_CLIENT/oc-mirror.tar.gz -o oc-mirror.tar.gz
tar -xvf oc-mirror.tar.gz
rm -f oc-mirror.tar.gz
chmod u+x oc-mirror
mv oc-mirror /usr/bin/
###################
# Step#3a: Create Local Net:
###################
# Need to do this before restarting NetworkManager, or else DNS fails as there isn't any 192.168.125.1 existing
# create cluster:
kcli create network -c 192.168.125.0/24 -P forward_mode=route -P dhcp=false --domain tnc.bootcamp.lab tnc
kcli create network -c 192.168.126.0/24 -P dhcp=false --domain tnc.bootcamp.lab tnc-connected
logger "Done with 3a"
###################
# Step#3b: DNS:
###################
dnf install dnsmasq

cat << EOF > /etc/NetworkManager/conf.d/dnsmasq.conf
[main]
dns=dnsmasq
[connection]
ipv4.dns-priority=200
ipv6.dns-priority=200
EOF

cat << EOF > /etc/NetworkManager/dnsmasq.d/main.conf
# listen-address=192.168.125.1
server=8.8.8.8
domain=tnc.bootcamp.lab
EOF

cat << EOF > /etc/NetworkManager/dnsmasq.d/hub.conf
address=/api.hub.tnc.bootcamp.lab/192.168.125.100
address=/api-int.hub.tnc.bootcamp.lab/192.168.125.100
address=/.apps.hub.tnc.bootcamp.lab/192.168.125.100
address=/quay.tnc.bootcamp.lab/192.168.125.1
EOF
sleep 10
systemctl reload NetworkManager.service
systemctl restart NetworkManager.service 
systemctl enable NetworkManager.service --now  # to avoid issues faced in case of reoload of host
logger "done with 3b"
logger "checking NetworkManager:"
systemctl is-active NetworkManager | xargs logger

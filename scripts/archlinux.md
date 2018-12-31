
systemctl disable systemd-resolved
systemctl stop systemd-resolved

https://wiki.archlinux.org/index.php/IPv6#Disable_IPv6
net.ipv6.conf.all.disable_ipv6 = 1


echo "nameserver 192.168.1.1" >> /etc/resolv.conf
echo "search example.com" >> /etc/resolv.conf
echo "127.0.0.1 $(hostname)" >> /etc/hosts
echo "127.0.1.1 $(hostname).example.com" >> /etc/hosts

# install docker

# load modules

modprobe xt_conntrack nf_nat

# kubelet etc to /usr/local/bin

CRICTL_VERSION="v1.11.1"
curl -L "https://github.com/kubernetes-incubator/cri-tools/releases/download/${CRICTL_VERSION}/crictl-${CRICTL_VERSION}-linux-arm64.tar.gz" | tar -C /usr/local/bin -xz

CNI_VERSION="v0.6.0"
mkdir -p /opt/cni/bin
curl -L "https://github.com/containernetworking/plugins/releases/download/${CNI_VERSION}/cni-plugins-arm64-${CNI_VERSION}.tgz" | tar -C /opt/cni/bin -xz

RELEASE="$(curl -sSL https://dl.k8s.io/release/stable.txt)"

cd /usr/local/bin
curl -L --remote-name-all https://storage.googleapis.com/kubernetes-release/release/${RELEASE}/bin/linux/arm64/{kubeadm,kubelet,kubectl}
chmod +x {kubeadm,kubelet,kubectl}

curl -sSL "https://raw.githubusercontent.com/kubernetes/kubernetes/${RELEASE}/build/debs/kubelet.service" | sed "s:/usr/bin:/usr/local/bin:g" > /etc/systemd/system/kubelet.service
mkdir -p /etc/systemd/system/kubelet.service.d
curl -sSL "https://raw.githubusercontent.com/kubernetes/kubernetes/${RELEASE}/build/debs/10-kubeadm.conf" | sed "s:/usr/bin:/usr/local/bin:g" > /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

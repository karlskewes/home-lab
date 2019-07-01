# Terraform

## Local machine

**DNS Caching:**

If you're running `systemd-resolve` (likely on Ubuntu) then it may cache KVM
guest DNS records and this is a pain if doing lots of loops involving `terraform
apply, ssh $guest, terraform destroy`.

```
# Flush local DNS cache - consider saving as a bash function
sudo systemd-resolve --flush-caches
```

## KVM Host

### Enable IP Forwarding with sysctl.conf

[Libvirt
docs](https://wiki.libvirt.org/page/Net.bridge.bridge-nf-call_and_sysctl.conf)
```
# Enable IP forwarding
sudo cat <<EOF >> /etc/sysctl.conf
net.ipv4.ip_forward=1
net.ipv6.conf.all.forwarding=1
net.bridge.bridge-nf-call-arptables = 0
net.bridge.bridge-nf-call-ip6tables = 0
net.bridge.bridge-nf-call-iptables = 0
EOF

# update sysctl manually (run once on boot)
sudo sysctl -p
```


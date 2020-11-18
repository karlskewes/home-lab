Upgrading nodes, k8s versions is hard, see: https://typhoon.psdn.io/topics/maintenance/#upgrades

Naively destroying a vm and then `cd typhoon & terraform apply` results in the
kubelet service starting on the new node but the rest of the cluster going
NotReady. Spent zero time looking at this but it's probably because new CA
certs, etc have been created.

Possibly selective destroy and apply might work, might need to handle manual
kubectl delete <old-node>

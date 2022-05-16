virsh shutdown syed-cluster_super1
virsh shutdown syed-cluster_super2
virsh shutdown syed-cluster_super3
virsh attach-device --config syed-cluster_super1 /root/storage1.xml
virsh attach-device --config syed-cluster_super2 /root/storage2.xml
virsh attach-device --config syed-cluster_super3 /root/storage3.xml
virsh start syed-cluster_super1
virsh start syed-cluster_super2
virsh start syed-cluster_super3

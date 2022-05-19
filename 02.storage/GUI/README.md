== Step 4: 

yaml file that previously was being used for this step: ../04_ODF_Operator.yml 
The operation seemed to work even with the original yaml. 

The yaml generated using GUI deployment are: 

* *Operator*
[mano@pool2-infra1 GUI]$ oc get operators.operators.coreos.com | grep storage
local-storage-operator.openshift-local-storage   23h
mcg-operator.openshift-storage                   23h
ocs-operator.openshift-storage                   23h
odf-csi-addons-operator.openshift-storage        23h
odf-operator.openshift-storage                   23h

** oc get operators.operators.coreos.com odf-operator.openshift-storage -o yaml > odf-operator.yml

* *Subscription*

[mano@pool2-infra1 GUI]$ oc -n openshift-storage get subscription 
NAME                                                              PACKAGE                   SOURCE             CHANNEL
mcg-operator-stable-4.10-redhat-operators-openshift-marketplace   mcg-operator              redhat-operators   stable-4.10
ocs-operator-stable-4.10-redhat-operators-openshift-marketplace   ocs-operator              redhat-operators   stable-4.10
odf-csi-addons-operator                                           odf-csi-addons-operator   redhat-operators   stable-4.10
odf-operator                                                      odf-operator              redhat-operators   stable-4.10

** oc -n openshift-storage get subscription odf-operator -o yaml > odf-operator-subs.yml

== Step 5: 

yaml file that previously was being used for this step: i

../05_ODF_Cluster.yml --> This one was manually generated. Didn't work, giving errors about node not being avaiable

../05_ODF_Cluster_from_GUI.yml --> This one was generated from the GUI (failed) deployment. Didn't work, giving rbd failure errors
(This is the file that was being tried most recently, and failed)

The operation failed to work even with the original yaml. 

The yaml generated now using GUI deployment are: 

* *StorageCluster* 
[mano@pool2-infra1 GUI]$ oc get storageclusters.ocs.openshift.io -n openshift-storage 
NAME                 AGE   PHASE   EXTERNAL   CREATED AT             VERSION
ocs-storagecluster   23h   Ready              2022-05-18T17:14:35Z   4.10.0

** oc get storageclusters.ocs.openshift.io -n openshift-storage ocs-storagecluster -o yaml > storage-cluster.yml 

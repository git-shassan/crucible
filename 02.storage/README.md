Steps:
https://docs.openshift.com/container-platform/4.10/storage/persistent_storage/persistent-storage-local.html

Verification
oc -n openshift-local-storage get pods
oc get csvs -n openshift-local-storage

Notes:
- The Local Storage Operator automatically creates the storage class if it does not exist. 
- You will need to add the ODF label to each OCP node that has storage devices used to create the ODF storage cluster. The ODF operator looks for this label to know which nodes can be scheduling targets for ODF components. You must have a minimum of three labeled nodes with the same number of devices or disks with similar performance capability. (https://red-hat-storage.github.io/ocs-training/training/ocs4/odf4-install-no-ui.html) 




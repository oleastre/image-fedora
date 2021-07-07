# Scaleway image build

## Deployment steps

1.  Setup the fefora version you want to target
    ```
    export FEDORA_VERSION=34
    ```
2.  Create a new DEV1-M instance with two 20GB disks
    ```
    scw instance server create \
      type=DEV1-M \
      image=debian_buster \
      root-volume=l:20G \
      additional-volumes.0=l:20G \
      name=fedora-builder \
      ip=new
    ```

3.  Get some instance infos:
    ```
    export BUILDER_ID=$(scw instance server list name=fedora-builder -o json|jq -r ".[0].id")
    export BUILDER_IP=$(scw instance server get $BUILDER_ID -o json |jq -r ".public_ip.address")
    ssh-keygen -R $BUILDER_IP
    ```

4.  Run the ansible playbook on the newly created instance
    ```
    ansible-playbook -u debian -i $BUILDER_IP, fedora$FEDORA_VERSION.yaml
    ```

5. Poweroff the builder machine
    ```
    ssh debian@$BUILDER_IP sudo poweroff
    sleep 1m
    scw instance server stop $BUILDER_ID
    sleep 1m
    ```

6. Create an image of the fedora disk
    ```
    export BUILDER_VOLUME=$(scw instance server get $BUILDER_ID -o json|jq -r ".Volumes[1].id")
    scw instance snapshot create name=fedora$FEDORA_VERSION volume-id=$BUILDER_VOLUME
    sleep 30s
    export SNAPSHOT_ID=$(scw instance snapshot list name=fedora$FEDORA_VERSION -o json |jq -r .[0].id)
    scw instance image create name=fedora$FEDORA_VERSION snapshot-id=$SNAPSHOT_ID arch=x86_64
    export IMAGE_ID=$(scw instance image list name=fedora$FEDORA_VERSION -o json |jq -r ".[0].id")
    ```
7.  Create a new instance from the image to test
    ```
    scw instance server create \
    type=DEV1-S \
    image=$IMAGE_ID \
    root-volume=l:10G \
    additional-volumes.0=l:10G \
    name=fedora-image-test \
    ip=new
    ```
8.  Connect to the test machine and do some smoke tests
    ```
    export TEST_IMAGE_ID=$(scw instance server list name=fedora-image-test -o json |jq -r ".[0].id")
    export TEST_IMAGE_IP=$(scw instance server get $TEST_IMAGE_ID -o json|jq -r ".public_ip.address")
    ssh-keygen -R $TEST_IMAGE_IP
    ssh fedora@$TEST_IMAGE_IP cat /etc/os-release
9.  Cleanup the test and builder, release ip addresses.
    ```
    scw instance server terminate $TEST_IMAGE_ID with-ip=true
    scw instance server delete $BUILDER_ID with-ip=true
    scw instance ip delete $TEST_IMAGE_IP
    scw instance ip delete $BUILDER_IP
    ```
10. Enjoy a new server
    As the image is only 10GB, the root storage is quite limited, but sufficient to store everything, data included. The rest can be assigned to a local data storage.

    Data should be stored on an external block device detached from the instance (allow to rebuild the instance after os update).

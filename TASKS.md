# Tasks

* Initialize and boot up Vagrant with a CentOS image
  * `vagrant init chef/centos-6.5; vagrant up --provider virtualbox` [X]
* Enable shell provisioning
  * Enable shell provisioner [X]
  * Create shell script for provisioning [X]
  * Test with vagrant provision [X]
* Install Docker with shell provisioner
  * Confirm that we have a 3.8 or later kernel version [?]. Kind of not very
    smart to install an unsupported kernel in RHEL/CentOS.
  * Check for Device Mapper [X]
  * Add EPEL
    * Check for EPEL [X]
    * Install EPEL repo [X]
  * Install Docker
    * yum -y install docker-io [X]
* Start the Docker daemon 
  * Enable the service [X]
  * Start the service [X]
  * Confirm that it is running [X]


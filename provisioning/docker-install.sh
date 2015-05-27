is_kernel_more_recent_than() {
    echo "Checking for supported Kernel version..."
    local v=$(uname -r | cut -d\- -f1 | tr -d '.' | tr -d '[A-Z][a-z]')
    v=${v:0:4}
    if [ $v -ge $1 ]; then
        return 0;
    else
        return 1;
    fi
}

handle_old_kernel() {
    echo "Kernel version ($(uname -r)) too old. Trying to update."
    update_packages
    echo "Packages updated. Try to rerun the provisioning script now."
    exit 1
}

update_packages() {
    echo "Updating packages..."
    yum makecache
    yum -y update

    local status=$?
    if [ $status -ne 0 ]; then
        echo "Fatal: Package update failed"
        exit 1
    fi
}

has_device_mapper() {
    echo "Checking for Device Mapper..."
    stat /sys/class/misc/device-mapper > /dev/null 2>&1
    return $?
}

install_device_mapper() {
    yum -y install device-mapper
    modprobe dm_mod
}

main() {
    # According to the Docker book, we need the kernel to be 
    # 3.8 or newer. RHEL/CentOS by definition runs on 2.6.x 
    # kernels so that's not really possible.
    local kver_required=2632
    is_kernel_more_recent_than $kver_required || handle_old_kernel
    has_device_mapper || install_device_mapper
}

main $*

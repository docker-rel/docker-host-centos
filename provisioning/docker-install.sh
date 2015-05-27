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
    echo "Kernel version ($(uname -r)) too old."
    exit 1
}

update_packages() {
    echo "Updating packages..."
    update_package_cache || exit 1
    yum -y update > $LOGFILE 2>&1

    local status=$?
    if [ $status -ne 0 ]; then
        echo "Fatal: Package update failed"
        exit 1
    fi
}

has_device_mapper() {
    echo "Checking for Device Mapper..."
    stat /sys/class/misc/device-mapper > $LOGFILE 2>&1
    return $?
}

install_device_mapper() {
    echo "Installing Device Mapper"
    yum -y install device-mapper
    modprobe dm_mod
    return $?
}

has_epel() {
    echo "Checking for EPEL..."
    yum repolist | grep '^epel' > $LOGFILE 2>&1
    return $?
}

install_epel() {
    echo "Installing EPEL repo..."
    local epel_rpm="http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm"
    rpm -ivh $epel_rpm > $LOGFILE 2>&1
}

update_package_cache() {
    echo "Updating package cache..."
    yum makecache > $LOGFILE 2>&1
    return $?
}

has_docker() {
    echo "Checking if Docker is installed..."
    rpm -q docker-io > $LOGFILE 2>&1
    return $?
}

install_docker() {
    echo "Installing Docker..."
    yum -y install docker-io > $LOGFILE 2>&1
    return $?
}

is_docker_running() {
    echo "Checking if Docker is running..."
    service docker status > $LOGFILE 2>&1
    return $?
}

enable_docker() {
    echo "Enabling Docker daemon..."
    chkconfig docker on > $LOGFILE 2>&1
    return $?
}

start_docker() {
    echo "Starting Docker daemon..."
    service docker start > $LOGFILE 2>&1
    return $?
}

main() {
    # According to the Docker book, we need the kernel to be 
    # 3.8 or newer. RHEL/CentOS by definition runs on 2.6.x 
    # kernels so that's not really possible.
    local kver_required=2632
    echo "Installation log in $LOGFILE"

    update_packages

    has_docker || ( \
        ( is_kernel_more_recent_than $kver_required || handle_old_kernel ) && \
        ( has_device_mapper || install_device_mapper ) && \
        ( has_epel || ( install_epel && update_package_cache ) ) && \
        install_docker \
        )

    is_docker_running || ( enable_docker && start_docker )

    docker info || exit 1
}

LOGFILE=/tmp/docker-install.log

main $*

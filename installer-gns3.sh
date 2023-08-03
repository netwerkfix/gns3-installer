clear
sleep 3
echo "
##################################
#### Netwerkfix GNS3 installer ###
##################################
"
sleep 2
apt update ; apt upgrade -y
sleep 2
useradd -p $(openssl passwd -1 Test.1234) gns3
sleep 2
apt install software-properties-common -y
sleep 1
apt install libvirt-clients -y
sleep 1
sudo add-apt-repository ppa:gns3/ppa
sleep 1
sudo apt update && sudo apt install gns3-gui gns3-server -y
sleep 2
sudo dpkg --add-architecture i386 && sudo apt update ; sudo apt install gns3-iou -y && apt-transport-https ca-certificates curl software-properties-common -y
sleep 2
sudo apt install docker docker-compose -y && sudo usermod -aG ubridge root; sudo usermod -aG libvirt root; sudo usermod -aG kvm root; sudo usermod -aG wireshark root; sudo usermod -aG docker root
sleep 2
systemctl enable --now gns3server.service && systemctl enable --now docker
sleep 2
echo "[Server]
; IP where the server listen for connection
host = 0.0.0.0
; HTTP port for controlling the servers
port = 3080
; Path where images of devices are stored
images_path = /root/GNS3/images
; Path where user project are stored
projects_path = /root/GNS3/projects
; Send crash to the GNS3 team
report_errors = True
; First port of the range allocated to devices telnet console
console_start_port_range = 2001
; Last port of the range allocated to devices telnet console
console_end_port_range = 5000
; First port of the range allocated to communication between devices. You need two port by link
udp_start_port_range = 10000
; Last port of the range allocated to communication between devices. You need two port by link
udp_end_port_range = 20000
; Path of the ubridge program
ubridge_path = /usr/bin/ubridge
; Boolean for enabling HTTP auth
auth = True
; Username for HTTP auth
user = gns3
; Password for HTTP auth
password = gns3

[VPCS]
; Path of the VPCS binary
vpcs_path = /usr/bin/vpcs

[Dynamips]
allocate_aux_console_ports = False
mmap_support = True
; Path of the dynamips path
dynamips_path = /usr/bin/dynamips
sparse_memory_support = True
ghost_ios_support = True

[IOU]
; Path of the iouyap binary
iouyap_path = /usr/bin/iouyap
; Path of your .iourc file. If empty we search in $HOME/.iourc
iourc_path = /home/GNS3/.iourc
; Validate if the iourc is correct. If you turn off and your licence is invalid iou will crash without errors
license_check = True

[VirtualBox]
; Path of the VBoxManage command
vboxmanage_path = /usr/bin/VBoxManage
; Run VirtualBox with sudo as vbox_user
vbox_user =

[VMware]
; Type of Virtualization product (fusion, player, workstation)
host_type = fusion
; First vmnet adapter controlled by GNS3
vmnet_start_range = 2
; Last vmnet adapter controlled by GNS3
vmnet_end_range = 50
; Path of the vmrun executable
vmrun_path = /Applications/VMware Fusion.app/Contents/Library/vmrun" > gns3_server.conf
sleep 2
cp gns3_server.conf /root/.config/GNS3/2.2/
sleep 2
clear
sleep 2
echo "
#####################################################################################
## Gns3 Is succes installed now we are running Cockpit, Firewall rules and Bridges ##
#####################################################################################
"
sleep 3
sudo apt install cockpit -y && sudo apt install cockpit-machines -y && apt-get install iptables-persistent -y
sleep 1
iptables -t nat -I POSTROUTING 1 -s 192.168.0.0/16 -d 192.168.0.0/16 -j ACCEPT
sleep 1
iptables -I FORWARD 1 -s 192.168.0.0/16 -d 192.168.0.0/16 -j ACCEPT
sleep 1
iptables-save > /etc/iptables/rules.v4
sleep 3
for i in {3..9}
do
echo "<network>
  <name>isp$i</name>
  <forward mode='nat' dev='bond0'/>
  <bridge name='virbr$i' stp='on' delay='2'/>
  <ip address='192.168.12$i.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='192.168.12$i.100' end='192.168.12$i.254'/>
      <host name='isp$i' ip='192.168.12$i.2'/>
    </dhcp>
  </ip>
</network>" > /tmp/isp$i.xml
sleep 1
virsh net-define /tmp/isp$i.xml
sleep 1
virsh net-start isp$i
sleep 2
virsh net-autostart isp$i
done
sleep 3
clear
sleep 2
echo "
#############################################################################################################
##  Cockpit, Firewall rules and Bridges Is succes installed and configured now the last steps to configure ##
#############################################################################################################
"
sleep 2
cd /etc/libvirt/
sleep 1
echo "
# Master configuration file for the QEMU driver.
# All settings described here are optional - if omitted, sensible
# defaults are used.

# Use of TLS requires that x509 certificates be issued. The default is
# to keep them in /etc/pki/qemu. This directory must contain
#
#  ca-cert.pem - the CA master certificate
#  server-cert.pem - the server certificate signed with ca-cert.pem
#  server-key.pem  - the server private key
#
# and optionally may contain
#
#  dh-params.pem - the DH params configuration file
#
# If the directory does not exist, libvirtd will fail to start. If the
# directory doesn't contain the necessary files, QEMU domains will fail
# to start if they are configured to use TLS.
#
# In order to overwrite the default path alter the following. This path
# definition will be used as the default path for other *_tls_x509_cert_dir
# configuration settings if their default path does not exist or is not
# specifically set.
#
#default_tls_x509_cert_dir = "/etc/pki/qemu"

user = "root"
group = "root"
remember_owner = 0

# The default TLS configuration only uses certificates for the server
# allowing the client to verify the server's identity and establish
# an encrypted channel.
#
# It is possible to use x509 certificates for authentication too, by
# issuing an x509 certificate to every client who needs to connect.
#
# Enabling this option will reject any client who does not have a
# certificate signed by the CA in /etc/pki/qemu/ca-cert.pem
#
# The default_tls_x509_cert_dir directory must also contain
#
#  client-cert.pem - the client certificate signed with the ca-cert.pem
#  client-key.pem - the client private key
#
# If this option is supplied it provides the default for the "_verify" option
# of specific TLS users such as vnc, backups, migration, etc. The specific
# users of TLS may override this by setting the specific "_verify" option.
#
# When not supplied the specific TLS users provide their own defaults.
#
#default_tls_x509_verify = 1

#
# Libvirt assumes the server-key.pem file is unencrypted by default.
# To use an encrypted server-key.pem file, the password to decrypt
# the PEM file is required. This can be provided by creating a secret
# object in libvirt and then to uncomment this setting to set the UUID
# of the secret.
#
# NB This default all-zeros UUID will not work. Replace it with the
# output from the UUID for the TLS secret from a 'virsh secret-list'
# command and then uncomment the entry
#
#default_tls_x509_secret_uuid = "00000000-0000-0000-0000-000000000000"


# VNC is configured to listen on 127.0.0.1 by default.
# To make it listen on all public interfaces, uncomment
# this next option.
#
# NB, strong recommendation to enable TLS + x509 certificate
# verification when allowing public access
#
#vnc_listen = "0.0.0.0"

# Enable this option to have VNC served over an automatically created
# unix socket. This prevents unprivileged access from users on the
# host machine, though most VNC clients do not support it.
#
# This will only be enabled for VNC configurations that have listen
# type=address but without any address specified. This setting takes
# preference over vnc_listen.
#
#vnc_auto_unix_socket = 1

# Enable use of TLS encryption on the VNC server. This requires
# a VNC client which supports the VeNCrypt protocol extension.
# Examples include vinagre, virt-viewer, virt-manager and vencrypt
# itself. UltraVNC, RealVNC, TightVNC do not support this
#
# It is necessary to setup CA and issue a server certificate
# before enabling this.
#
#vnc_tls = 1


# In order to override the default TLS certificate location for
# vnc certificates, supply a valid path to the certificate directory.
# If the provided path does not exist, libvirtd will fail to start.
# If the path is not provided, but vnc_tls = 1, then the
# default_tls_x509_cert_dir path will be used.
#
#vnc_tls_x509_cert_dir = "/etc/pki/libvirt-vnc"


# Uncomment and use the following option to override the default secret
# UUID provided in the default_tls_x509_secret_uuid parameter.
#
#vnc_tls_x509_secret_uuid = "00000000-0000-0000-0000-000000000000"


# The default TLS configuration only uses certificates for the server
# allowing the client to verify the server's identity and establish
# an encrypted channel.
#
# It is possible to use x509 certificates for authentication too, by
# issuing an x509 certificate to every client who needs to connect.
#
# Enabling this option will reject any client that does not have a
# certificate (as described in default_tls_x509_verify) signed by the
# CA in the vnc_tls_x509_cert_dir (or default_tls_x509_cert_dir).
#
# If this option is not supplied, it will be set to the value of
# "default_tls_x509_verify". If "default_tls_x509_verify" is not supplied either,
# the default is "0".
#
#vnc_tls_x509_verify = 1


# The default VNC password. Only 8 bytes are significant for
# VNC passwords. This parameter is only used if the per-domain
# XML config does not already provide a password. To allow
# access without passwords, leave this commented out. An empty
# string will still enable passwords, but be rejected by QEMU,
# effectively preventing any use of VNC. Obviously change this
# example here before you set this.
#
#vnc_password = "XYZ12345"


# Enable use of SASL encryption on the VNC server. This requires
# a VNC client which supports the SASL protocol extension.
# Examples include vinagre, virt-viewer and virt-manager
# itself. UltraVNC, RealVNC, TightVNC do not support this
#
# It is necessary to configure /etc/sasl2/qemu.conf to choose
# the desired SASL plugin (eg, GSSPI for Kerberos)
#
#vnc_sasl = 1


# The default SASL configuration file is located in /etc/sasl2/
# When running libvirtd unprivileged, it may be desirable to
# override the configs in this location. Set this parameter to
# point to the directory, and create a qemu.conf in that location
#
#vnc_sasl_dir = "/some/directory/sasl2"


# QEMU implements an extension for providing audio over a VNC connection,
# though if your VNC client does not support it, your only chance for getting
# sound output is through regular audio backends. By default, libvirt will
# disable all QEMU sound backends if using VNC, since they can cause
# permissions issues. Enabling this option will make libvirtd honor the
# QEMU_AUDIO_DRV environment variable when using VNC.
#
#vnc_allow_host_audio = 0



# SPICE is configured to listen on 127.0.0.1 by default.
# To make it listen on all public interfaces, uncomment
# this next option.
#
# NB, strong recommendation to enable TLS + x509 certificate
# verification when allowing public access
#
#spice_listen = "0.0.0.0"


# Enable use of TLS encryption on the SPICE server.
#
# It is necessary to setup CA and issue a server certificate
# before enabling this.
#
#spice_tls = 1


# In order to override the default TLS certificate location for
# spice certificates, supply a valid path to the certificate directory.
# If the provided path does not exist, libvirtd will fail to start.
# If the path is not provided, but spice_tls = 1, then the
# default_tls_x509_cert_dir path will be used.
#
#spice_tls_x509_cert_dir = "/etc/pki/libvirt-spice"


# Enable this option to have SPICE served over an automatically created
# unix socket. This prevents unprivileged access from users on the
# host machine.
#
# This will only be enabled for SPICE configurations that have listen
# type=address but without any address specified. This setting takes
# preference over spice_listen.
#
#spice_auto_unix_socket = 1


# The default SPICE password. This parameter is only used if the
# per-domain XML config does not already provide a password. To
# allow access without passwords, leave this commented out. An
# empty string will still enable passwords, but be rejected by
# QEMU, effectively preventing any use of SPICE. Obviously change
# this example here before you set this.
#
#spice_password = "XYZ12345"


# Enable use of SASL encryption on the SPICE server. This requires
# a SPICE client which supports the SASL protocol extension.
#
# It is necessary to configure /etc/sasl2/qemu.conf to choose
# the desired SASL plugin (eg, GSSPI for Kerberos)
#
#spice_sasl = 1

# The default SASL configuration file is located in /etc/sasl2/
# When running libvirtd unprivileged, it may be desirable to
# override the configs in this location. Set this parameter to
# point to the directory, and create a qemu.conf in that location
#
#spice_sasl_dir = "/some/directory/sasl2"

# Enable use of TLS encryption on the chardev TCP transports.
#
# It is necessary to setup CA and issue a server certificate
# before enabling this.
#
#chardev_tls = 1


# In order to override the default TLS certificate location for character
# device TCP certificates, supply a valid path to the certificate directory.
# If the provided path does not exist, libvirtd will fail to start.
# If the path is not provided, but chardev_tls = 1, then the
# default_tls_x509_cert_dir path will be used.
#
#chardev_tls_x509_cert_dir = "/etc/pki/libvirt-chardev"


# The default TLS configuration only uses certificates for the server
# allowing the client to verify the server's identity and establish
# an encrypted channel.
#
# It is possible to use x509 certificates for authentication too, by
# issuing an x509 certificate to every client who needs to connect.
#
# Enabling this option will reject any client that does not have a
# certificate (as described in default_tls_x509_verify) signed by the
# CA in the chardev_tls_x509_cert_dir (or default_tls_x509_cert_dir).
#
# If this option is not supplied, it will be set to the value of
# "default_tls_x509_verify". If "default_tls_x509_verify" is not supplied either,
# the default is "1".
#
#chardev_tls_x509_verify = 1


# Uncomment and use the following option to override the default secret
# UUID provided in the default_tls_x509_secret_uuid parameter.
#
# NB This default all-zeros UUID will not work. Replace it with the
# output from the UUID for the TLS secret from a 'virsh secret-list'
# command and then uncomment the entry
#
#chardev_tls_x509_secret_uuid = "00000000-0000-0000-0000-000000000000"


# Enable use of TLS encryption for all VxHS network block devices that
# don't specifically disable.
#
# When the VxHS network block device server is set up appropriately,
# x509 certificates are required for authentication between the clients
# (qemu processes) and the remote VxHS server.
#
# It is necessary to setup CA and issue the client certificate before
# enabling this.
#
#vxhs_tls = 1


# In order to override the default TLS certificate location for VxHS
# backed storage, supply a valid path to the certificate directory.
# This is used to authenticate the VxHS block device clients to the VxHS
# server.
#
# If the provided path does not exist, libvirtd will fail to start.
# If the path is not provided, but vxhs_tls = 1, then the
# default_tls_x509_cert_dir path will be used.
#
# VxHS block device clients expect the client certificate and key to be
# present in the certificate directory along with the CA master certificate.
# If using the default environment, default_tls_x509_verify must be configured.
# Since this is only a client the server-key.pem certificate is not needed.
# Thus a VxHS directory must contain the following:
#
#  ca-cert.pem - the CA master certificate
#  client-cert.pem - the client certificate signed with the ca-cert.pem
#  client-key.pem - the client private key
#
#vxhs_tls_x509_cert_dir = "/etc/pki/libvirt-vxhs"


# Uncomment and use the following option to override the default secret
# UUID provided in the default_tls_x509_secret_uuid parameter.
#
# NB This default all-zeros UUID will not work. Replace it with the
# output from the UUID for the TLS secret from a 'virsh secret-list'
# command and then uncomment the entry
#
#vxhs_tls_x509_secret_uuid = "00000000-0000-0000-0000-000000000000"


# Enable use of TLS encryption for all NBD disk devices that don't
# specifically disable it.
#
# When the NBD server is set up appropriately, x509 certificates are required
# for authentication between the client and the remote NBD server.
#
# It is necessary to setup CA and issue the client certificate before
# enabling this.
#
#nbd_tls = 1


# In order to override the default TLS certificate location for NBD
# backed storage, supply a valid path to the certificate directory.
# This is used to authenticate the NBD block device clients to the NBD
# server.
#
# If the provided path does not exist, libvirtd will fail to start.
# If the path is not provided, but nbd_tls = 1, then the
# default_tls_x509_cert_dir path will be used.
#
# NBD block device clients expect the client certificate and key to be
# present in the certificate directory along with the CA certificate.
# Since this is only a client the server-key.pem certificate is not needed.
# Thus a NBD directory must contain the following:
#
#  ca-cert.pem - the CA master certificate
#  client-cert.pem - the client certificate signed with the ca-cert.pem
#  client-key.pem - the client private key
#
#nbd_tls_x509_cert_dir = "/etc/pki/libvirt-nbd"


# Uncomment and use the following option to override the default secret
# UUID provided in the default_tls_x509_secret_uuid parameter.
#
# NB This default all-zeros UUID will not work. Replace it with the
# output from the UUID for the TLS secret from a 'virsh secret-list'
# command and then uncomment the entry
#
#nbd_tls_x509_secret_uuid = "00000000-0000-0000-0000-000000000000"


# In order to override the default TLS certificate location for migration
# certificates, supply a valid path to the certificate directory. If the
# provided path does not exist, libvirtd will fail to start. If the path is
# not provided, but TLS-encrypted migration is requested, then the
# default_tls_x509_cert_dir path will be used. Once/if a default certificate is
# enabled/defined, migration will then be able to use the certificate via
# migration API flags.
#
#migrate_tls_x509_cert_dir = "/etc/pki/libvirt-migrate"


# The default TLS configuration only uses certificates for the server
# allowing the client to verify the server's identity and establish
# an encrypted channel.
#
# It is possible to use x509 certificates for authentication too, by
# issuing an x509 certificate to every client who needs to connect.
#
# Enabling this option will reject any client that does not have a
# certificate (as described in default_tls_x509_verify) signed by the
# CA in the migrate_tls_x509_cert_dir (or default_tls_x509_cert_dir).
#
# If this option is not supplied, it will be set to the value of
# "default_tls_x509_verify". If "default_tls_x509_verify" is not supplied
# either, the default is "1".
#
#migrate_tls_x509_verify = 1


# Uncomment and use the following option to override the default secret
# UUID provided in the default_tls_x509_secret_uuid parameter.
#
# NB This default all-zeros UUID will not work. Replace it with the
# output from the UUID for the TLS secret from a 'virsh secret-list'
# command and then uncomment the entry
#
#migrate_tls_x509_secret_uuid = "00000000-0000-0000-0000-000000000000"


# By default TLS is requested using the VIR_MIGRATE_TLS flag, thus not requested
# automatically. Setting 'migate_tls_force' to "1" will prevent any migration
# which is not using VIR_MIGRATE_TLS to ensure higher level of security in
# deployments with TLS.
#
#migrate_tls_force = 0


# In order to override the default TLS certificate location for backup NBD
# server certificates, supply a valid path to the certificate directory. If the
# provided path does not exist, libvirtd will fail to start. If the path is
# not provided, but TLS-encrypted backup is requested, then the
# default_tls_x509_cert_dir path will be used.
#
#backup_tls_x509_cert_dir = "/etc/pki/libvirt-backup"


# The default TLS configuration only uses certificates for the server
# allowing the client to verify the server's identity and establish
# an encrypted channel.
#
# It is possible to use x509 certificates for authentication too, by
# issuing an x509 certificate to every client who needs to connect.
#
# Enabling this option will reject any client that does not have a
# certificate (as described in default_tls_x509_verify) signed by the
# CA in the backup_tls_x509_cert_dir (or default_tls_x509_cert_dir).
#
# If this option is not supplied, it will be set to the value of
# "default_tls_x509_verify". If "default_tls_x509_verify" is not supplied either,
# the default is "1".
#
#backup_tls_x509_verify = 1


# Uncomment and use the following option to override the default secret
# UUID provided in the default_tls_x509_secret_uuid parameter.
#
# NB This default all-zeros UUID will not work. Replace it with the
# output from the UUID for the TLS secret from a 'virsh secret-list'
# command and then uncomment the entry
#
#backup_tls_x509_secret_uuid = "00000000-0000-0000-0000-000000000000"


# By default, if no graphical front end is configured, libvirt will disable
# QEMU audio output since directly talking to alsa/pulseaudio may not work
# with various security settings. If you know what you're doing, enable
# the setting below and libvirt will passthrough the QEMU_AUDIO_DRV
# environment variable when using nographics.
#
#nographics_allow_host_audio = 1


# Override the port for creating both VNC and SPICE sessions (min).
# This defaults to 5900 and increases for consecutive sessions
# or when ports are occupied, until it hits the maximum.
#
# Minimum must be greater than or equal to 5900 as lower number would
# result into negative vnc display number.
#
# Maximum must be less than 65536, because higher numbers do not make
# sense as a port number.
#
#remote_display_port_min = 5900
#remote_display_port_max = 65535

# VNC WebSocket port policies, same rules apply as with remote display
# ports.  VNC WebSockets use similar display <-> port mappings, with
# the exception being that ports start from 5700 instead of 5900.
#
#remote_websocket_port_min = 5700
#remote_websocket_port_max = 65535

# The default security driver is SELinux. If SELinux is disabled
# on the host, then the security driver will automatically disable
# itself. If you wish to disable QEMU SELinux security driver while
# leaving SELinux enabled for the host in general, then set this
# to 'none' instead. It's also possible to use more than one security
# driver at the same time, for this use a list of names separated by
# comma and delimited by square brackets. For example:
#
#       security_driver = [ "selinux", "apparmor" ]
#
# Notes: The DAC security driver is always enabled; as a result, the
# value of security_driver cannot contain "dac".  The value "none" is
# a special value; security_driver can be set to that value in
# isolation, but it cannot appear in a list of drivers.
#
#security_driver = "selinux"

# If set to non-zero, then the default security labeling
# will make guests confined. If set to zero, then guests
# will be unconfined by default. Defaults to 1.
#security_default_confined = 1

# If set to non-zero, then attempts to create unconfined
# guests will be blocked. Defaults to 0.
#security_require_confined = 1

# The user for QEMU processes run by the system instance. It can be
# specified as a user name or as a user id. The qemu driver will try to
# parse this value first as a name and then, if the name doesn't exist,
# as a user id.
#
# Since a sequence of digits is a valid user name, a leading plus sign
# can be used to ensure that a user id will not be interpreted as a user
# name.
#
# By default libvirt runs VMs as non-root and uses AppArmor profiles
# to provide host protection and VM isolation. While AppArmor
# continues to provide this protection when the VMs are running as
# root, /dev/vhost-net, /dev/vhost-vsock and /dev/vhost-scsi access is
# allowed by default in the AppArmor security policy, so malicious VMs
# running as root would have direct access to this file. If changing this
# to run as root, you may want to remove this access from
# /etc/apparmor.d/abstractions/libvirt-qemu. For more information, see:
# https://launchpad.net/bugs/1815910
# https://www.redhat.com/archives/libvir-list/2019-April/msg00750.html
#
# Some examples of valid values are:
#
#       user = "qemu"   # A user named "qemu"
#       user = "+0"     # Super user (uid=0)
#       user = "100"    # A user named "100" or a user with uid=100
#
#user = "root"

# The group for QEMU processes run by the system instance. It can be
# specified in a similar way to user.
#group = "root"

# Whether libvirt should dynamically change file ownership
# to match the configured user/group above. Defaults to 1.
# Set to 0 to disable file ownership changes.
#dynamic_ownership = 1

# Whether libvirt should remember and restore the original
# ownership over files it is relabeling. Defaults to 1, set
# to 0 to disable the feature.
#remember_owner = 1

# What cgroup controllers to make use of with QEMU guests
#
#  - 'cpu' - use for scheduler tunables
#  - 'devices' - use for device access control
#  - 'memory' - use for memory tunables
#  - 'blkio' - use for block devices I/O tunables
#  - 'cpuset' - use for CPUs and memory nodes
#  - 'cpuacct' - use for CPUs statistics.
#
# NB, even if configured here, they won't be used unless
# the administrator has mounted cgroups, e.g.:
#
#  mkdir /dev/cgroup
#  mount -t cgroup -o devices,cpu,memory,blkio,cpuset none /dev/cgroup
#
# They can be mounted anywhere, and different controllers
# can be mounted in different locations. libvirt will detect
# where they are located.
#
#cgroup_controllers = [ "cpu", "devices", "memory", "blkio", "cpuset", "cpuacct" ]

# This is the basic set of devices allowed / required by
# all virtual machines.
#
# As well as this, any configured block backed disks,
# all sound device, and all PTY devices are allowed.
#
# This will only need setting if newer QEMU suddenly
# wants some device we don't already know about.
#
#cgroup_device_acl = [
#    "/dev/null", "/dev/full", "/dev/zero",
#    "/dev/random", "/dev/urandom",
#    "/dev/ptmx", "/dev/kvm"
#]
#
# RDMA migration requires the following extra files to be added to the list:
#   "/dev/infiniband/rdma_cm",
#   "/dev/infiniband/issm0",
#   "/dev/infiniband/issm1",
#   "/dev/infiniband/umad0",
#   "/dev/infiniband/umad1",
#   "/dev/infiniband/uverbs0"


# The default format for QEMU/KVM guest save images is raw; that is, the
# memory from the domain is dumped out directly to a file.  If you have
# guests with a large amount of memory, however, this can take up quite
# a bit of space.  If you would like to compress the images while they
# are being saved to disk, you can also set "lzop", "gzip", "bzip2", or "xz"
# for save_image_format.  Note that this means you slow down the process of
# saving a domain in order to save disk space; the list above is in descending
# order by performance and ascending order by compression ratio.
#
# save_image_format is used when you use 'virsh save' or 'virsh managedsave'
# at scheduled saving, and it is an error if the specified save_image_format
# is not valid, or the requested compression program can't be found.
#
# dump_image_format is used when you use 'virsh dump' at emergency
# crashdump, and if the specified dump_image_format is not valid, or
# the requested compression program can't be found, this falls
# back to "raw" compression.
#
# snapshot_image_format specifies the compression algorithm of the memory save
# image when an external snapshot of a domain is taken. This does not apply
# on disk image format. It is an error if the specified format isn't valid,
# or the requested compression program can't be found.
#
#save_image_format = "raw"
#dump_image_format = "raw"
#snapshot_image_format = "raw"

# When a domain is configured to be auto-dumped when libvirtd receives a
# watchdog event from qemu guest, libvirtd will save dump files in directory
# specified by auto_dump_path. Default value is /var/lib/libvirt/qemu/dump
#
#auto_dump_path = "/var/lib/libvirt/qemu/dump"

# When a domain is configured to be auto-dumped, enabling this flag
# has the same effect as using the VIR_DUMP_BYPASS_CACHE flag with the
# virDomainCoreDump API.  That is, the system will avoid using the
# file system cache while writing the dump file, but may cause
# slower operation.
#
#auto_dump_bypass_cache = 0

# When a domain is configured to be auto-started, enabling this flag
# has the same effect as using the VIR_DOMAIN_START_BYPASS_CACHE flag
# with the virDomainCreateWithFlags API.  That is, the system will
# avoid using the file system cache when restoring any managed state
# file, but may cause slower operation.
#
#auto_start_bypass_cache = 0

# If provided by the host and a hugetlbfs mount point is configured,
# a guest may request huge page backing.  When this mount point is
# unspecified here, determination of a host mount point in /proc/mounts
# will be attempted.  Specifying an explicit mount overrides detection
# of the same in /proc/mounts.  Setting the mount point to "" will
# disable guest hugepage backing. If desired, multiple mount points can
# be specified at once, separated by comma and enclosed in square
# brackets, for example:
#
#     hugetlbfs_mount = ["/dev/hugepages2M", "/dev/hugepages1G"]
#
# The size of huge page served by specific mount point is determined by
# libvirt at the daemon startup.
#
# NB, within these mount points, guests will create memory backing
# files in a location of $MOUNTPOINT/libvirt/qemu
#
#hugetlbfs_mount = "/dev/hugepages"


# Path to the setuid helper for creating tap devices.  This executable
# is used to create <source type='bridge'> interfaces when libvirtd is
# running unprivileged.  libvirt invokes the helper directly, instead
# of using "-netdev bridge", for security reasons.
#bridge_helper = "/usr/libexec/qemu-bridge-helper"


# If enabled, libvirt will have QEMU set its process name to
# "qemu:VM_NAME", where VM_NAME is the name of the VM. The QEMU
# process will appear as "qemu:VM_NAME" in process listings and
# other system monitoring tools. By default, QEMU does not set
# its process title, so the complete QEMU command (emulator and
# its arguments) appear in process listings.
#
#set_process_name = 1


# If max_processes is set to a positive integer, libvirt will use
# it to set the maximum number of processes that can be run by qemu
# user. This can be used to override default value set by host OS.
# The same applies to max_files which sets the limit on the maximum
# number of opened files.
#
#max_processes = 0
#max_files = 0

# If max_threads_per_process is set to a positive integer, libvirt
# will use it to set the maximum number of threads that can be
# created by a qemu process. Some VM configurations can result in
# qemu processes with tens of thousands of threads. systemd-based
# systems typically limit the number of threads per process to
# 16k. max_threads_per_process can be used to override default
# limits in the host OS.
#
#max_threads_per_process = 0

# If max_core is set to a non-zero integer, then QEMU will be
# permitted to create core dumps when it crashes, provided its
# RAM size is smaller than the limit set.
#
# Be warned that the core dump will include a full copy of the
# guest RAM, if the 'dump_guest_core' setting has been enabled,
# or if the guest XML contains
#
#   <memory dumpcore="on">...guest ram...</memory>
#
# If guest RAM is to be included, ensure the max_core limit
# is set to at least the size of the largest expected guest
# plus another 1GB for any QEMU host side memory mappings.
#
# As a special case it can be set to the string "unlimited" to
# to allow arbitrarily sized core dumps.
#
# By default the core dump size is set to 0 disabling all dumps
#
# Size is a positive integer specifying bytes or the
# string "unlimited"
#
#max_core = "unlimited"

# Determine if guest RAM is included in QEMU core dumps. By
# default guest RAM will be excluded if a new enough QEMU is
# present. Setting this to '1' will force guest RAM to always
# be included in QEMU core dumps.
#
# This setting will be ignored if the guest XML has set the
# dumpcore attribute on the <memory> element.
#
#dump_guest_core = 1

# mac_filter enables MAC addressed based filtering on bridge ports.
# This currently requires ebtables to be installed.
#
#mac_filter = 1


# By default, PCI devices below non-ACS switch are not allowed to be assigned
# to guests. By setting relaxed_acs_check to 1 such devices will be allowed to
# be assigned to guests.
#
#relaxed_acs_check = 1


# In order to prevent accidentally starting two domains that
# share one writable disk, libvirt offers two approaches for
# locking files. The first one is sanlock, the other one,
# virtlockd, is then our own implementation. Accepted values
# are "sanlock" and "lockd".
#
#lock_manager = "lockd"


# Set limit of maximum APIs queued on one domain. All other APIs
# over this threshold will fail on acquiring job lock. Specially,
# setting to zero turns this feature off.
# Note, that job lock is per domain.
#
#max_queued = 0

###################################################################
# Keepalive protocol:
# This allows qemu driver to detect broken connections to remote
# libvirtd during peer-to-peer migration.  A keepalive message is
# sent to the daemon after keepalive_interval seconds of inactivity
# to check if the daemon is still responding; keepalive_count is a
# maximum number of keepalive messages that are allowed to be sent
# to the daemon without getting any response before the connection
# is considered broken.  In other words, the connection is
# automatically closed approximately after
# keepalive_interval * (keepalive_count + 1) seconds since the last
# message received from the daemon.  If keepalive_interval is set to
# -1, qemu driver will not send keepalive requests during
# peer-to-peer migration; however, the remote libvirtd can still
# send them and source libvirtd will send responses.  When
# keepalive_count is set to 0, connections will be automatically
# closed after keepalive_interval seconds of inactivity without
# sending any keepalive messages.
#
#keepalive_interval = 5
#keepalive_count = 5



# Use seccomp syscall filtering sandbox in QEMU.
# 1 == filter enabled, 0 == filter disabled
#
# Unless this option is disabled, QEMU will be run with
# a seccomp filter that stops it from executing certain
# syscalls.
#
#seccomp_sandbox = 1


# Override the listen address for all incoming migrations. Defaults to
# 0.0.0.0, or :: if both host and qemu are capable of IPv6.
#migration_address = "0.0.0.0"


# The default hostname or IP address which will be used by a migration
# source for transferring migration data to this host.  The migration
# source has to be able to resolve this hostname and connect to it so
# setting "localhost" will not work.  By default, the host's configured
# hostname is used.
#migration_host = "host.example.com"


# Override the port range used for incoming migrations.
#
# Minimum must be greater than 0, however when QEMU is not running as root,
# setting the minimum to be lower than 1024 will not work.
#
# Maximum must not be greater than 65535.
#
#migration_port_min = 49152
#migration_port_max = 49215



# Timestamp QEMU's log messages (if QEMU supports it)
#
# Defaults to 1.
#
#log_timestamp = 0


# Location of master nvram file
#
# This configuration option is obsolete. Libvirt will follow the
# QEMU firmware metadata specification to automatically locate
# firmware images. See docs/interop/firmware.json in the QEMU
# source tree. These metadata files are distributed alongside any
# firmware images intended for use with QEMU.
#
# NOTE: if ANY firmware metadata files are detected, this setting
# will be COMPLETELY IGNORED.
#
# ------------------------------------------
#
# When a domain is configured to use UEFI instead of standard
# BIOS it may use a separate storage for UEFI variables. If
# that's the case libvirt creates the variable store per domain
# using this master file as image. Each UEFI firmware can,
# however, have different variables store. Therefore the nvram is
# a list of strings when a single item is in form of:
#   ${PATH_TO_UEFI_FW}:${PATH_TO_UEFI_VARS}.
# Later, when libvirt creates per domain variable store, this list is
# searched for the master image. The UEFI firmware can be called
# differently for different guest architectures. For instance, it's OVMF
# for x86_64 and i686, but it's AAVMF for aarch64. The libvirt default
# follows this scheme.
#nvram = [
#   "/usr/share/OVMF/OVMF_CODE.fd:/usr/share/OVMF/OVMF_VARS.fd",
#   "/usr/share/OVMF/OVMF_CODE.secboot.fd:/usr/share/OVMF/OVMF_VARS.fd",
#   "/usr/share/AAVMF/AAVMF_CODE.fd:/usr/share/AAVMF/AAVMF_VARS.fd",
#   "/usr/share/AAVMF/AAVMF32_CODE.fd:/usr/share/AAVMF/AAVMF32_VARS.fd",
#   "/usr/share/OVMF/OVMF_CODE.ms.fd:/usr/share/OVMF/OVMF_VARS.ms.fd"
#]

# The backend to use for handling stdout/stderr output from
# QEMU processes.
#
#  'file': QEMU writes directly to a plain file. This is the
#          historical default, but allows QEMU to inflict a
#          denial of service attack on the host by exhausting
#          filesystem space
#
#  'logd': QEMU writes to a pipe provided by virtlogd daemon.
#          This is the current default, providing protection
#          against denial of service by performing log file
#          rollover when a size limit is hit.
#
#stdio_handler = "logd"

# QEMU gluster libgfapi log level, debug levels are 0-9, with 9 being the
# most verbose, and 0 representing no debugging output.
#
# The current logging levels defined in the gluster GFAPI are:
#
#    0 - None
#    1 - Emergency
#    2 - Alert
#    3 - Critical
#    4 - Error
#    5 - Warning
#    6 - Notice
#    7 - Info
#    8 - Debug
#    9 - Trace
#
# Defaults to 4
#
#gluster_debug_level = 9

# virtiofsd debug
#
# Whether to enable the debugging output of the virtiofsd daemon.
# Possible values are 0 or 1. Disabled by default.
#
#virtiofsd_debug = 1

# To enhance security, QEMU driver is capable of creating private namespaces
# for each domain started. Well, so far only "mount" namespace is supported. If
# enabled it means qemu process is unable to see all the devices on the system,
# only those configured for the domain in question. Libvirt then manages
# devices entries throughout the domain lifetime. This namespace is turned on
# by default.
#namespaces = [ "mount" ]

# This directory is used for memoryBacking source if configured as file.
# NOTE: big files will be stored here
#memory_backing_dir = "/var/lib/libvirt/qemu/ram"

# Path to the SCSI persistent reservations helper. This helper is
# used whenever <reservations/> are enabled for SCSI LUN devices.
#pr_helper = "/usr/bin/qemu-pr-helper"

# Path to the SLIRP networking helper.
#slirp_helper = "/usr/bin/slirp-helper"

# Path to the dbus-daemon
#dbus_daemon = "/usr/bin/dbus-daemon"

# User for the swtpm TPM Emulator
#
# Default is 'swtpm' as established by the swtpm-tools package.
#
# In the past this was 'tss' and that still would be the built-in default
# if nothing was configured here, but the 'tss' user also has TPM device
# access in the host which isn't needed for swtpm.
#
swtpm_user = "swtpm"
swtpm_group = "swtpm"

# For debugging and testing purposes it's sometimes useful to be able to disable
# libvirt behaviour based on the capabilities of the qemu process. This option
# allows to do so. DO _NOT_ use in production and beaware that the behaviour
# may change across versions.
#
#capability_filters = [ "capname" ]

# 'deprecation_behavior' setting controls how the qemu process behaves towards
# deprecated commands and arguments used by libvirt.
#
# This setting is meant for developers and CI efforts to make it obvious when
# libvirt relies on fields which are deprecated so that it can be fixes as soon
# as possible.
#
# Possible options are:
# "none"   - (default) qemu is supposed to accept and output deprecated fields
#            and commands
# "omit"   - qemu is instructed to omit deprecated fields on output, behaviour
#            towards fields and commands from qemu is not changed
# "reject" - qemu is instructed to report an error if a deprecated command or
#            field is used by libvirtd
# "crash"  - qemu crashes when an deprecated command or field is used by libvirtd
#
# For both "reject" and "crash" qemu is instructed to omit any deprecated fields
# on output.
#
# The "reject" option is less harsh towards the VMs but some code paths ignore
# errors reported by qemu and thus it may not be obvious that a deprecated
# command/field was used, thus it's suggested to use the "crash" option instead.
#
# In cases when qemu doesn't support configuring the behaviour this setting is
# silently ignored to allow testing older qemu versions without having to
# reconfigure libvirtd.
#
# DO NOT use in production.
#
#deprecation_behavior = "none"
" > qemu.conf 
sleep 3
cd /root/
sleep 2
sysctl -w net.ipv4.ip_forward=1
sleep 1
systemctl enable --now libvirtd
sleep 1
systemctl enable --now gns3server.service
sleep 1
echo "
#####################################
## Gns3 Server                  ###
## IP: \4             ##
## User: gns3                   ###
## Pass: gns3                   ##
#####################################
" > /etc/issue
sleep 1
clear
sleep 3
echo "
##################################################
## GNS3 is succesfull installed                 ##
##                                              ##
## Check if all isp's are running and active ;) ##
##################################################
"
sleep 2
virsh net-list --all
sleep 7
clear
echo "
##################################################
## GNS3 is succesfull installed                 ##
##                                              ##
## your ready to used it :)                     ##
##################################################
"

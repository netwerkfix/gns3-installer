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
sleep 3
echo "[Server]
; IP where the server listen for connection
host = 192.168.122.1
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
sleep 7
cd /etc/libvirt/
sleep 1
echo "user = "root"
group = "root"
remember_owner = 0
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
systemctl restart libvirtd
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
cd /etc/systemd/system/
echo "[Unit]
Description=Netwerkfix-Auto-Updates

[Service]
#ExecStartPre=
ExecStart=/etc/auto-update.sh
SyslogIdentifier=Diskutilization
#ExecStop=

[Install]
WantedBy=multi-user.target" > auto-update.service
sleep 2
cd /etc/
sleep 1
echo "#!/bin/bash
######################################################
#### WARNING PIPING TO BASH IS STUPID: DO NOT USE THIS
######################################################
# TESTED ON UBUNTU 22.04.1 LTS (Works for me)

# this command give the script sudo perms

if [ `id -u` -ne 0 ]; then
	echo Need sudo
	exit 1
fi

set -v

sleep 9
####  Auto-Updating ####
apt update && apt upgrade -y
sleep 2629743
apt update && apt upgrade -y
### Reboot System ###
reboot" > auto-update.sh
sleep 1
chmod 755 auto-update.sh
sleep 1
cd /root/
systemctl enable --now auto-update.service
sleep 2
cd /etc/systemd/system/
echo "[Unit]
Description=Netwerkfix-Dhcp-Bug-Fix

[Service]
#ExecStartPre=
ExecStart=/etc/dhcp-fix.sh
SyslogIdentifier=Diskutilization
#ExecStop=

[Install]
WantedBy=multi-user.target" > dhcp-fix.service
sleep 2
cd /etc/
sleep 1
echo "#!/bin/bash
######################################################
#### WARNING PIPING TO BASH IS STUPID: DO NOT USE THIS
######################################################
# TESTED ON UBUNTU 22.04.1 LTS (Works for me)

# this command give the script sudo perms

if [ `id -u` -ne 0 ]; then
	echo Need sudo
	exit 1
fi

set -v

sleep 6
## Dhcp Fix ##
dhclient" > dhcp-fix.sh
sleep 1
chmod 755 dhcp-fix.sh
sleep 1
cd /root/
systemctl enable --now dhcp-fix.service
sleep 2
cd /etc/systemd/system/
echo "[Unit]
Description=Netwerkfix-Force-Start-Gns3

[Service]
#ExecStartPre=
ExecStart=/etc/gns3-fix.sh
SyslogIdentifier=Diskutilization
#ExecStop=

[Install]
WantedBy=multi-user.target" > gns3-fix.service
sleep 2
cd /etc/
sleep 1
echo "#!/bin/bash
######################################################
#### WARNING PIPING TO BASH IS STUPID: DO NOT USE THIS
######################################################
# TESTED ON UBUNTU 22.04.1 LTS (Works for me)

# this command give the script sudo perms

if [ `id -u` -ne 0 ]; then
	echo Need sudo
	exit 1
fi

set -v

sleep 6
## Gns3 Force Start ##
systemctl enable --now gns3server.service" > gns3-fix.sh
sleep 1
chmod 755 gns3-fix.sh
sleep 1
cd /root/
systemctl enable --now gns3-fix.service
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
sleep 5
virsh net-list --all
sleep 10
clear
echo "
##################################################
## GNS3 is succesfull installed                 ##
##                                              ##
## your ready to used it :)                     ##
##################################################
"
sleep 2

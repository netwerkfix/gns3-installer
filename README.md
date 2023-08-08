# GNS3-Installer script
<br>
<h4>go first to root user with</h4>
$ sudo su
<h4>or</h4>
$ sudo root
<h4>Download the installer</h4>
$ wget https://netwerkfix.ams3.digitaloceanspaces.com/gns3-installer/Gns3-Installer.sh
<br>
<h4>Check first in the script that bridges change bond0 to your uplink interface</h4>
$ nano Gns3-install.sh
<h5>Save it</h5>
<br>
<h4>Give it run perms</h4>
$ chmod +x Gns3-install.sh
<br>
<h4>Execute it / Run the installer and just wait :)</h4>
$ ./Gns3-install.sh

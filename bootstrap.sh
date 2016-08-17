# Increase disk size on base box to 100MB

cd ~/.vagrant.d/boxes/ubuntu-VAGRANTSLASH-trusty64/20*/virtualbox
vboxmanage clonehd "box-disk1.vmdk" "clone.vdi" --format vdi
rm box-disk1.vmdk
vboxmanage modifyhd "clone.vdi" --resize 100000
vboxmanage clonehd "clone.vdi" "box-disk1.vmdk" --format vmdk
rm clone.vdi


Vagrant.configure(2) do |config|

  # Configure virtual machine settings
  config.vm.box = "ubuntu/trusty64"
  config.vm.hostname = "datastage2go"
  config.vm.define "datastage2go" do |t|
  end
  config.vm.provider :virtualbox do |vb|
    vb.memory = 1024
    vb.name = "datastage2go"
  end

  # Configure provisioning
  config.vm.synced_folder "config/", "/home/vagrant/sync"
  config.vm.provision "shell", path: "users.sh"
  config.vm.provision "shell", path: "dependencies.sh"
  config.vm.provision "shell", path: "database_config.sh"

end

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

  # Ensure vbguest updates
  config.vbguest.auto_reboot = true
  config.vbguest.auto_update = true

  # Configure provisioning
  config.vm.synced_folder "config/", "/home/vagrant/sync"
  config.vm.provision "shell", path: "scripts/users.sh"
  config.vm.provision "shell", path: "scripts/dependencies.sh"
  config.vm.provision "shell", path: "scripts/database_config.sh"
  config.vm.provision "shell", path: "scripts/aws_config.sh"
  # config.vm.provision "shell", path: "scripts/openedx_etl.sh"

end

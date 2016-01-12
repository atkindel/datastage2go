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

  # Provision software
  config.vm.provision "shell", path: "scripts/users.sh"
  config.vm.provision "shell", path: "scripts/dependencies.sh"
  config.vm.provision "shell", path: "scripts/database_config.sh"

  # Provision AWS configuration files
  config.vm.provision "file", source: "~/.ssh/.boto", destination: "/home/vagrant/sync/.boto"
  config.vm.provision "file", source: "~/.ssh/.s3cfg", destination: "/home/vagrant/sync/.s3cfg"
  config.vm.provision "shell", path: "scripts/aws_config.sh"

end

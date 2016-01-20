# Copyright (c) 2014, Stanford University
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

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

  # Set modulestore location
  modulestore_location = "None"

  # Provision software
  config.vm.provision "shell", path: "scripts/users.sh"
  config.vm.provision "shell", path: "scripts/dependencies.sh"
  config.vm.provision "shell", path: "scripts/database_config.sh", args: modulestore_location

  # Provision AWS configuration files
  config.vm.provision "file", source: "~/.ssh/.boto", destination: "/home/vagrant/sync/.boto"
  config.vm.provision "file", source: "~/.ssh/.s3cfg", destination: "/home/vagrant/sync/.s3cfg"
  config.vm.provision "shell", path: "scripts/aws_config.sh"

end

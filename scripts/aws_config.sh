COLOR="\033[1;35m"
COLOR_RST="\033[0m"


# Move files over for main user
echo -e "${COLOR}---Configuring AWS credentials...---${COLOR_RST}"

  sudo chmod 777 /home/vagrant/sync/
  sudo cp /home/vagrant/sync/limits.conf /etc/security/limits.conf
  sudo cp /home/vagrant/sync/s3.txt /home/dataman/.s3cfg
  sudo cp /home/vagrant/sync/boto.cfg /home/dataman/.boto

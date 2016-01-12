COLOR="\033[1;35m"
COLOR_RST="\033[0m"

# Create main user
echo -e "${COLOR}---Moving AWS config files...---${COLOR_RST}"

  # Move files
  mkdir /home/dataman/.ssh
  mv /home/vagrant/sync/.boto /home/dataman/
  mv /home/vagrant/sync/.s3cfg /home/dataman/
  echo "root" > /home/dataman/.ssh/mysql_root

  # Set permissions
  chown dataman:dataman /home/dataman/.boto
  chown dataman:dataman /home/dataman/.s3cfg
  chmod 700 /home/dataman/.boto
  chmod 700 /home/dataman/.s3cfg
  chown -R dataman:dataman /home/dataman/.ssh/
  chmod -R 700 /home/dataman/.ssh

  # Clean up sync directory
  sudo rm -rf /home/vagrant/sync

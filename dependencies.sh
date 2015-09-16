COLOR="\033[1;35m"
COLOR_RST="\033[0m"

# Install system modules
echo -e "${COLOR}---Installing system modules...---${COLOR_RST}"

  echo -e "${COLOR}---git---${COLOR_RST}"
  sudo apt-get -y install git

  # echo -e "${COLOR}---virtualenvwrapper---${COLOR_RST}"
  # sudo apt-get -y install virtualenvwrapper

  echo -e "${COLOR}---MySQL server---${COLOR_RST}"
  sudo apt-get -y install debconf-utils > /dev/null
  sudo debconf-set-selections <<< 'mysql-server-5.6 mysql-server/root_password password root'
  sudo debconf-set-selections <<< 'mysql-server-5.6 mysql-server/root_password_again password root'
  sudo apt-get -y install mysql-server-5.6

  echo -e "${COLOR}---MySQL libraries---${COLOR_RST}"
  sudo apt-get -y install libmysqlclient-dev

  echo -e "${COLOR}---Python---${COLOR_RST}"
  sudo apt-get -y install python-dev

  echo -e "${COLOR}---Python interface to S3---${COLOR_RST}"
  sudo apt-get -y install python-boto

  echo -e "${COLOR}---Python interface to MySQL---${COLOR_RST}"
  sudo apt-get -y install python-mysqldb

  echo -e "${COLOR}---GNU Parallel---${COLOR_RST}"
  sudo apt-get -y install parallel

  echo -e "${COLOR}---MongoDB---${COLOR_RST}"
  sudo apt-get -y install mongodb

  echo -e "${COLOR}---Amazon S3 CLI---${COLOR_RST}"
  sudo apt-get -y install s3cmd

  # echo -e "${COLOR}---Remote machine backups---${COLOR_RST}"
  # sudo apt-get -y install sshfs

  echo -e "${COLOR}---PHP---${COLOR_RST}"
  sudo apt-get -y install php5
  sudo apt-get -y install php5-mysqlnd
  sudo php5enmod mysqli

  # echo -e "${COLOR}---Python autoenv---${COLOR_RST}"
  # yes | sudo pip install autoenv

  # echo -e "${COLOR}---Numpy---${COLOR_RST}"
  # yes | sudo pip install numpy  #Turn off numpy unless really needed


# Disable apparmor
echo -e "${COLOR}---Disabling apparmor...---${COLOR_RST}"

  sudo /etc/init.d/apparmor stop
  sudo update-rc.d -f apparmor remove
  sudo ln -s /etc/apparmor.d/usr.sbin.mysqld /etc/apparmor.d/disable/
  sudo apparmor_parser -R /etc/apparmor.d/usr.sbin.mysqld


# Done installing dependencies
echo -e "${COLOR}---Finished installing dependencies.---${COLOR_RST}"

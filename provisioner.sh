COLOR="\033[1;35m"
COLOR_RST="\033[0m"

# Create main user and switch over
echo -e "${COLOR}------Adding main user...------${COLOR_RST}"

  sudo adduser databoss
  sudo adduser databoss sudo
  echo "databoss:databoss" | chpasswd
  sudo su databoss


# Install system modules
echo -e "${COLOR}---Installing system modules...---${COLOR_RST}"

  echo -e "${COLOR}---git---${COLOR_RST}"
  sudo apt-get -y install git

  echo -e "${COLOR}---virtualenvwrapper---${COLOR_RST}"
  sudo apt-get -y install virtualenvwrapper

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

  echo -e "${COLOR}---Remote machine backups---${COLOR_RST}"
  sudo apt-get -y install sshfs

  echo -e "${COLOR}---PHP---${COLOR_RST}"
  sudo apt-get -y install php5
  sudo apt-get -y install php5-mysqlnd
  sudo php5enmod mysqli

  echo -e "${COLOR}---Python modules---${COLOR_RST}"
  yes | sudo pip install autoenv
  # yes | sudo pip install numpy  #Turn off numpy unless really needed


# Disable apparmor
echo -e "${COLOR}---Disabling apparmor...---${COLOR_RST}"

  sudo /etc/init.d/apparmor stop
  sudo update-rc.d -f apparmor remove
  sudo ln -s /etc/apparmor.d/usr.sbin.mysqld /etc/apparmor.d/disable/
  sudo apparmor_parser -R /etc/apparmor.d/usr.sbin.mysqld


# Move files over for main user
echo -e "${COLOR}---Setting up necessary directories---${COLOR_RST}"

  sudo cp -r /home/vagrant/sync/ /home/databoss/config/

  cd /home/databoss/config/

  # sudo mkdir /lfs/datastage2go/0/tmp/
  # sudo mkdir -p /lfs/datastage2go/0/home/mysql/tables/
  # sudo mv /var/lib/mysql/mysql /lfs/datastage2go/0/home/mysql/tables/
  # sudo chown -R mysql:mysql /lfs/datastage2/0/home/mysql/

  # sudo mv my.cnf /etc/mysql/
  sudo mv limits.conf /etc/security/limits.conf
  sudo mv s3.txt /home/databoss/.s3cfg
  sudo mv bashFuncs.txt /home/databoss/.bashFuncs
  sudo mv boto.cfg /home/databoss/.boto
  sudo mv ./ssh/ /home/databoss/.ssh/


# Git setup
echo -e "${COLOR}---Configuring git...---${COLOR_RST}"

  source /home/databoss/config/git.cfg
  git config --global user.email $gituseremail
  git config --global user.name $gitusername
  git config --global push.default simple

# Clone needed repositories
echo -e "${COLOR}---Cloning ETL software...---${COLOR_RST}"

  mkdir /home/databoss/Code
  cd /home/databoss/Code
  git clone https://github.com/paepcke/json_to_relation.git
  cd json_to_relation
  python setup.py install

  # # Below might be unneeded
  # cd /home/databoss/Code
  # git clone https://github.com/paepcke/pymysql_utils.git
  # cd pymysql_utils
  # python setup.py install


# Create data export directories
echo -e "${COLOR}---Making data output directories...---${COLOR_RST}"

  mkdir -p /home/databoss/Data/CustomExcerpts
  mkdir -p /home/databoss/Data/FullDumps
  mkdir -p /home/databoss/Data/FullDumps/EdxAppPlatformDbs/
  mkdir -p /home/databoss/Data/FullDumps/EdxForum/
	mkdir -p /home/databoss/Data/EdX/tracking/CSV
	mkdir -p /home/databoss/Data/EdX/tracking/TransformLogs
	mkdir -p /home/databoss/Data/EdX/NonTransformLogs


# Prepare database
echo -e "${COLOR}---Preparing database...---${COLOR_RST}"

  cd /home/databoss/Code/json_to_relation
  sudo mysqld
  DBSETUP="CREATE DATABASE IF NOT EXISTS unittests;
           FLUSH PRIVILEGES;
           CREATE USER 'unittest'@'localhost' IDENTIFIED BY 'unittest';
           CREATE USER 'databoss'@'localhost';
           GRANT ALL ON unittests.* TO 'unittest'@'localhost';
           GRANT ALL ON *.* TO 'databoss'@'localhost';
           GRANT ALL ON *.* TO 'databoss'@'%';"
  sudo mysql -proot -e "$DBSETUP"
  echo "forumkeypassphrase" > scripts/forumKeyPassphrase.txt
  yes Y | sudo scripts/createEmptyEdxDbs.sh

  # Keep the database local


# Set up table export interface


### Datastage2Go?

COLOR="\033[1;35m"
COLOR_RST="\033[0m"

# Move files over for main user
echo -e "${COLOR}---Setting up necessary directories---${COLOR_RST}"

  sudo su databoss
  cd ~

  sudo cp -r /home/vagrant/sync/ /home/databoss/config/

  sudo mv /home/databoss/config/limits.conf /etc/security/limits.conf
  sudo mv /home/databoss/config/s3.txt /home/databoss/.s3cfg
  sudo mv /home/databoss/config/boto.cfg /home/databoss/.boto


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

  echo -e "${COLOR}---Starting database...---${COLOR_RST}"
  cd /home/databoss/Code/json_to_relation
  sudo mysqld

  echo -e "${COLOR}---Building user permissions...---${COLOR_RST}"
  DBSETUP="CREATE DATABASE IF NOT EXISTS unittests;
           FLUSH PRIVILEGES;
           CREATE USER 'unittest'@'localhost' IDENTIFIED BY 'unittest';
           CREATE USER 'databoss'@'localhost';
           GRANT ALL ON unittests.* TO 'unittest'@'localhost';
           GRANT ALL ON *.* TO 'databoss'@'localhost';
           GRANT ALL ON *.* TO 'databoss'@'%';"
  sudo mysql -proot -e "$DBSETUP"

  echo -e "${COLOR}---Creating empty databases...---${COLOR_RST}"
  echo "forumkeypassphrase" > scripts/forumKeyPassphrase.txt
  yes Y | sudo scripts/createEmptyEdxDbs.sh

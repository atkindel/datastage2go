COLOR="\033[1;35m"
COLOR_RST="\033[0m"

# Move files over for main user
echo -e "${COLOR}---Configuring AWS credentials...---${COLOR_RST}"

  sudo chmod 777 /home/vagrant/sync/
  sudo cp /home/vagrant/sync/limits.conf /etc/security/limits.conf
  sudo cp /home/vagrant/sync/s3.txt /home/databoss/.s3cfg
  sudo cp /home/vagrant/sync/boto.cfg /home/databoss/.boto


# Git setup
echo -e "${COLOR}---Configuring git...---${COLOR_RST}"

  source /home/vagrant/sync/git.cfg
  git config --global user.email "$gituseremail"
  git config --global user.name "$gitusername"
  git config --global push.default simple


# Clone needed repositories
echo -e "${COLOR}---Cloning OpenEdX ETL software...---${COLOR_RST}"

  mkdir /home/databoss/Code/
  sudo chmod 777 /home/databoss/Code/
  cd /home/databoss/Code/
  git clone https://github.com/paepcke/json_to_relation.git
  cd json_to_relation
  sudo python setup.py install


# Create data export directories
echo -e "${COLOR}---Making data output directories...---${COLOR_RST}"

  cd /home/databoss/
  mkdir /home/databoss/Data/
  sudo chmod 777 /home/databoss/Data/

  mkdir -p /home/databoss/Data/CustomExcerpts
  mkdir -p /home/databoss/Data/FullDumps
  mkdir -p /home/databoss/Data/FullDumps/EdxAppPlatformDbs/
  mkdir -p /home/databoss/Data/FullDumps/EdxForum/
	mkdir -p /home/databoss/Data/EdX/tracking/CSV
	mkdir -p /home/databoss/Data/EdX/tracking/TransformLogs
	mkdir -p /home/databoss/Data/EdX/NonTransformLogs


# Quick fixes to MySQL login path
echo -e "${COLOR}---Setup MySQL authentication...---${COLOR_RST}"

  echo "[client]" >> /root/.my.cnf
  echo "password=root" >> /root/.my.cnf

  cd /home/databoss/Code/json_to_relation
  sed -i "s/--login-path=root//g" scripts/createEmptyEdxDbs.sh
  mysql_config_editor set --login-path=client --user=root
  sudo chmod -R 777 /var/lib/mysql/


# Prepare database
echo -e "${COLOR}---Preparing database...---${COLOR_RST}"

  cd /home/databoss/Code/json_to_relation

  echo -e "${COLOR}---Building user permissions...---${COLOR_RST}"
  DBSETUP="CREATE DATABASE IF NOT EXISTS unittest;
           FLUSH PRIVILEGES;
           CREATE USER 'unittest'@'localhost' IDENTIFIED BY 'unittest';
           CREATE USER 'databoss'@'localhost' IDENTIFIED BY 'databoss';
           GRANT ALL ON unittests.* TO 'unittest'@'localhost';
           GRANT ALL ON *.* TO 'databoss'@'localhost';
           GRANT ALL ON *.* TO 'databoss'@'%';"
  sudo mysql -e "$DBSETUP"

  echo -e "${COLOR}---Creating empty databases...---${COLOR_RST}"
  echo "forumkeypassphrase" > scripts/forumKeyPassphrase.txt
  yes Y | sudo scripts/createEmptyEdxDbs.sh

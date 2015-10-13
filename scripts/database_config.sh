COLOR="\033[1;35m"
COLOR_RST="\033[0m"


# Git setup
echo -e "${COLOR}---Configuring git...---${COLOR_RST}"

  source /home/vagrant/sync/git.cfg
  git config --global user.email "$gituseremail"
  git config --global user.name "$gitusername"
  git config --global push.default simple


# Clone needed repositories
echo -e "${COLOR}---Cloning OpenEdX ETL software...---${COLOR_RST}"

  mkdir /home/dataman/Code/
  sudo chmod 777 /home/dataman/Code/
  cd /home/dataman/Code/
  git clone https://github.com/paepcke/json_to_relation.git
  cd json_to_relation
  sudo python setup.py install

  cd ..
  git clone https://github.com/paepcke/online_learning_computations.git
  cd online_learning_computations
  sudo python setup.py install

  cd ..
  git clone https://github.com/Stanford-Online/forum_etl.git
  cd forum_etl
  python setup.py install
  # look at this as an example for openedx_etl.sh


# Create data export directories
echo -e "${COLOR}---Making data output directories...---${COLOR_RST}"

  cd /home/dataman/
  mkdir /home/dataman/Data/
  sudo chmod 777 /home/dataman/Data/

  mkdir -p /home/dataman/Data/CustomExcerpts
  mkdir -p /home/dataman/Data/FullDumps
  mkdir -p /home/dataman/Data/FullDumps/EdxAppPlatformDbs/
  mkdir -p /home/dataman/Data/FullDumps/EdxForum/
	mkdir -p /home/dataman/Data/EdX/tracking/CSV
	mkdir -p /home/dataman/Data/EdX/tracking/TransformLogs
	mkdir -p /home/dataman/Data/EdX/NonTransformLogs


# Quick fixes to MySQL login path
echo -e "${COLOR}---Setup MySQL authentication...---${COLOR_RST}"

  echo "[client]" >> /root/.my.cnf
  echo "password=root" >> /root/.my.cnf

  cd /home/dataman/Code/json_to_relation
  sed -i "s/--login-path=root//g" scripts/createEmptyEdxDbs.sh
  mysql_config_editor set --login-path=client --user=root
  sudo chmod -R 777 /var/lib/mysql/


# Prepare database
echo -e "${COLOR}---Preparing database...---${COLOR_RST}"

  cd /home/dataman/Code/json_to_relation

  echo -e "${COLOR}---Building user permissions...---${COLOR_RST}"
  DBSETUP="CREATE DATABASE IF NOT EXISTS unittest;
           FLUSH PRIVILEGES;
           CREATE USER 'unittest'@'localhost' IDENTIFIED BY 'unittest';
           CREATE USER 'dataman'@'localhost' IDENTIFIED BY 'dataman';
           GRANT ALL ON unittests.* TO 'unittest'@'localhost';
           GRANT ALL ON *.* TO 'dataman'@'localhost';
           GRANT ALL ON *.* TO 'dataman'@'%';"
  sudo mysql -e "$DBSETUP"

  echo -e "${COLOR}---Creating empty databases...---${COLOR_RST}"
  echo "forumkeypassphrase" > scripts/forumKeyPassphrase.txt
  yes Y | sudo scripts/createEmptyEdxDbs.sh


echo -e "${COLOR}---Finished database configuration.---${COLOR_RST}"

# Copyright (c) 2014, Stanford University
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


COLOR="\033[1;35m"
COLOR_RST="\033[0m"


# Clone needed repositories
echo -e "${COLOR}---Cloning OpenEdX ETL software...---${COLOR_RST}"

  mkdir /home/dataman/Code/
  sudo chmod 777 /home/dataman/Code/
  cd /home/dataman/Code/
  git clone https://github.com/paepcke/json_to_relation.git
  cd json_to_relation
  sudo python setup.py install

  ## Below repositories are optional, but potentially helpful.
  ## Note that online_learning_computations requires numpy.

  # cd ..
  # git clone https://github.com/paepcke/online_learning_computations.git
  # cd online_learning_computations
  # sudo python setup.py install
  #
  # cd ..
  # git clone https://github.com/paepcke/forum_etl.git
  # cd forum_etl
  # python setup.py install

## The code below disables partitioning on the primary event log table. Use with caution.

#echo -e "${COLOR}---Excluding default partitioning...---${COLOR_RST}"

  # sudo sed -i "s/tableName == 'EdxTrackEvent'/tableName == 'NULL_TABLE'/g" /home/dataman/Code/json_to_relation/json_to_relation/edxTrackLogJSONParser.py
  # sudo sed -i '163,193d' scripts/createEmptyEdxDbs.sql
  # sudo sed -i '162s/$/;/' scripts/createEmptyEdxDbs.sql

echo -e "${COLOR}---Setting up localization...---${COLOR_RST}"

  sudo sed -i "s/EDX_PLATFORM_DUMP_MACHINE=jenkins.prod.class.stanford.edu/EDX_PLATFORM_DUMP_MACHINE=${1}/g" /home/dataman/Code/json_to_relation/scripts/cronRefreshModuleStore.sh


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
  sudo sed -i "s/--login-path=root//g" scripts/createEmptyEdxDbs.sh
  sudo sed -i "s/--login-path=root/-u root -p\$password/g" scripts/executeCSVBulkLoad.sh
  mysql_config_editor set --login-path=client --user=root
  sudo chmod -R 777 /var/lib/mysql


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

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

sudo apt-get install -f 
sudo apt-get update
echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

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

  echo -e "${COLOR}---Python autoenv---${COLOR_RST}"
  yes | sudo pip install autoenv

  echo -e "${COLOR}---GNU Parallel---${COLOR_RST}"
  sudo apt-get -y install parallel

  echo -e "${COLOR}---MongoDB---${COLOR_RST}"
  sudo apt-get -y install mongodb

  echo -e "${COLOR}---Amazon S3 CLI---${COLOR_RST}"
  sudo apt-get -y install s3cmd

  echo -e "${COLOR}---PHP---${COLOR_RST}"
  sudo apt-get -y install php5
  sudo apt-get -y install php5-mysqlnd
  sudo php5enmod mysqli

  echo -e "${COLOR}---Numpy---${COLOR_RST}"
  yes | sudo pip install numpy


# Disable apparmor
echo -e "${COLOR}---Disabling apparmor...---${COLOR_RST}"

  sudo /etc/init.d/apparmor stop
  sudo update-rc.d -f apparmor remove
  sudo ln -s /etc/apparmor.d/usr.sbin.mysqld /etc/apparmor.d/disable/
  sudo apparmor_parser -R /etc/apparmor.d/usr.sbin.mysqld


# Done installing dependencies
echo -e "${COLOR}---Finished installing dependencies.---${COLOR_RST}"

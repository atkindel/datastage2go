sudo -i

docker pull mysql:5.7

echo CONTAINER_NAME="edx-database" >> /root/.bashrc
echo MYSQL_ROOT_PASSWORD="password" >> /root/.bashrc

docker run --detach \
  --env MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD} \
  --name ${CONTAINER_NAME} \
  --publish 3306:3306 \
  mysql:5.7;

COLOR="\033[1;35m"
COLOR_RST="\033[0m"

sleep 10
docker inspect ${CONTAINER_NAME} > db-container-details.txt
export MYSQL_CONTAINER_IP=$(grep IPAddress db-container-details.txt | cut -c 14- | cut -d '"' -f2)
echo $MYSQL_CONTAINER_IP

echo -e "${COLOR}---Cloning OpenEdX ETL software...---${COLOR_RST}"

mkdir /home/dataman/Code/
sudo chmod 777 /home/dataman/Code

cd /home/dataman/Code/
git clone https://github.com/paepcke/json_to_relation.git
cd json_to_relation
sudo python setup.py install

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
 
echo -e "${COLOR}---Setup MySQL authentication...---${COLOR_RST}"

echo "[client]" >> /root/.my.cnf
echo "password=${MYSQL_ROOT_PASSWORD}" >> /root/.my.cnf
echo "port=3306" >> /root/.my.cnf
echo "host=${MYSQL_CONTAINER_IP}" >> /root/.my.cnf

cd /home/dataman/Code/json_to_relation
sed -i "s/--login-path=root//g" scripts/createEmptyEdxDbs.sh
sed -i "s/--login-path=root/-u root -p\$password/g" scripts/executeCSVBulkLoad.sh
chmod -R 777 /var/lib/mysql

echo -e "${COLOR}---Preparing database...---${COLOR_RST}"

DBSETUP="CREATE DATABASE IF NOT EXISTS unittest;
         FLUSH PRIVILEGES;
         CREATE USER 'unittest'@'localhost' IDENTIFIED BY 'unittest';
         CREATE USER 'dataman'@'localhost' IDENTIFIED BY 'dataman';
         CREATE USER 'dataman'@'%' IDENTIFIED BY 'dataman';
         GRANT ALL ON unittests.* TO 'unittest'@'localhost';
         GRANT ALL ON *.* TO 'dataman'@'localhost';
         GRANT ALL ON *.* TO 'dataman'@'%';"

mysql -e "$DBSETUP"

echo -e "${COLOR}---Creating empty databases...---${COLOR_RST}"
echo "forumkeypassphrase" > scripts/forumKeyPassphrase.txt
yes Y | sudo scripts/createEmptyEdxDbs.sh

cd /home/dataman
sudo chown -R dataman:dataman Code Data

echo -e "${COLOR}---Finished database configuration.---${COLOR_RST}"

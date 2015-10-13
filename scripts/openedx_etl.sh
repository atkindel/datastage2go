COLOR="\033[1;35m"
COLOR_RST="\033[0m"


# Test run load course data to database
echo -e "${COLOR}---Test run of OpenEdX ETL process...---${COLOR_RST}"

  sudo su root
  cd /home/dataman/Code/json_to_relation/
  echo "root" | sudo scripts/manageEdxDb.py --logsSrc /home/vagrant/sync/tracking.log-20141024-1414127821.gz -p transformLoad

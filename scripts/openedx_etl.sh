COLOR="\033[1;35m"
COLOR_RST="\033[0m"


# Dry run load course data to database
echo -e "${COLOR}---Dry run of OpenEdX ETL process...---${COLOR_RST}"

  sudo scripts/manageEdxDb.py --dryRun pullTransformLoad

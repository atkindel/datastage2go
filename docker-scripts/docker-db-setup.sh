yes Y | sudo yum install docker
yes Y | sudo yum install mysql
yes Y | sudo yum install python

docker pull mysql:latest


CONTAINER_NAME="edx-database"
MYSQL_ROOT_PASSWORD="password" # CHANGE HERE TO CHANGE THE ROOT PASSWORD

docker run --detach \
  --publish 3306:3306 \
  --env MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD} \
  --name ${CONTAINER_NAME} \
  mysql:latest;

COLOR="\033[1;35m"
COLOR_RST="\033[0m"

docker inspect ${CONTAINER_NAME} > db-container-details.txt
export MYSQL_CONTAINER_IP=$(grep "\"IPAddress\"" db-container-details.txt | cut -d '"' -f4 | sed -n 1p)
echo "IP_ADDRESS: $MYSQL_CONTAINER_IP"

echo -e "${COLOR}---Cloning OpenEdX ETL software...---${COLOR_RST}"

mkdir /home/ec2-user/dataman/
mkdir /home/ec2-user/dataman/Code/
sudo chmod 777 /home/ec2-user/dataman/Code

cd /home/ec2-user/dataman/Code/
git clone https://github.com/paepcke/json_to_relation.git
cd json_to_relation
sudo python setup.py install

echo -e "${COLOR}---Making data output directories...---${COLOR_RST}"

cd /home/ec2-user/dataman/
mkdir /home/ec2-user/dataman/Data/
sudo chmod 777 /home/ec2-user/dataman/Data/

  mkdir -p /home/ec2-user/dataman/Data/CustomExcerpts
  mkdir -p /home/ec2-user/dataman/Data/FullDumps
  mkdir -p /home/ec2-user/dataman/Data/FullDumps/EdxAppPlatformDbs/
  mkdir -p /home/ec2-user/dataman/Data/FullDumps/EdxForum/
  mkdir -p /home/ec2-user/dataman/Data/EdX/tracking/CSV
  mkdir -p /home/ec2-user/dataman/Data/EdX/tracking/TransformLogs
  mkdir -p /home/ec2-user/dataman/Data/EdX/NonTransformLogs
 
echo -e "${COLOR}---Setup MySQL authentication...---${COLOR_RST}"

echo "[client]" >> ~/.my.cnf
echo "user=root" >> ~/.my.cnf
echo "password=${MYSQL_ROOT_PASSWORD}" >> ~/.my.cnf
echo "port=3306" >> ~/.my.cnf
echo "host=${MYSQL_CONTAINER_IP}" >> ~/.my.cnf

cd /home/ec2-user/dataman/Code/json_to_relation
sed -i "s/--login-path=root//g" scripts/createEmptyEdxDbs.sh
sed -i "s/--login-path=root/-u root -p\$password/g" scripts/executeCSVBulkLoad.sh

echo -e "${COLOR}---Preparing database...---${COLOR_RST}"
sleep 10

cd /home/ec2-user/dataman/Code/json_to_relation
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
echo "forumkeypassphrase" > scripts/forumKeyPassphrase.txt # CHANGE THIS TO REFLECT THE FORUM KEY PASSPHRASE

echo "About to create tables"
mysql < scripts/createEmptyEdxDbs.sql
echo "Done creating tables"

echo "About to create procedures and functions."
  FORUM_KEY_PASSPHRASE=$(cat scripts/forumKeyPassphrase.txt)

  KEY_INSTALL_CMD="DROP TABLE IF EXISTS EdxPrivate.Keys; \
                   CREATE TABLE EdxPrivate.Keys (forumKey varchar(255) DEFAULT ''); \
                   INSERT INTO EdxPrivate.Keys SET forumKey = (SELECT SHA2('"$FORUM_KEY_PASSPHRASE"',224) AS forumKey);"

  mysql EdxPrivate -e "$KEY_INSTALL_CMD"

  mysql Edx < scripts/mysqlProcAndFuncBodies.sql 
  mysql EdxPrivate < scripts/mysqlProcAndFuncBodies.sql 
  mysql EdxForum < scripts/mysqlProcAndFuncBodies.sql 
  mysql EdxPiazza < scripts/mysqlProcAndFuncBodies.sql 
  mysql edxprod < scripts/mysqlProcAndFuncBodies.sql 
  mysql EdxQualtrics < scripts/mysqlProcAndFuncBodies.sql 
  mysql unittest < scripts/mysqlProcAndFuncBodies.sql 

echo "Done creating procedures and functions."

echo "Starting index creation."
  declare -A allTables
  allTables=( ["EdxTrackEvent"]="Edx" \
              ["Answer"]="Edx" \
              ["CorrectMap"]="Edx" \
              ["InputState"]="Edx" \
              ["LoadInfo"]="Edx" \
              ["State"]="Edx" \
              ["ActivityGrade"]="Edx" \
              ["ABExperiment"]="Edx" \
              ["OpenAssessment"]="Edx" \
              ["Account"]="EdxPrivate" \
              ["UserCountry"]="Edx" \
  )

  tables=${!allTables[@]}
  
  for table in ${tables[@]}
do
    if [ $table == 'EdxTrackEvent' ]
    then
	# The '${allTables["$table"]}' parts below resolve to the database in which the respective table resides:

	# If creating indexes on an already populated table, you would
	# use the following for increased efficiency (one statement for
	# all indexes). But if any of the index(es) exists, I think
	# this statement would bomb. So we instead use the form below,
	# with one statement per index. On an empty table this is perfectly
	# fast:
	    # echo "Creating index on EdxTrackEvent(event_type) if needed..."
	    # mysql -u $USERNAME $pwdOption Edx -e "ALTER TABLE EdxTrackEvent
	    #   ADD INDEX EdxTrackEventIdxEvType (event_type(255)),
	    #   ADD INDEX EdxTrackEventIdxIdxUname (anon_screen_name(40)),
	    #   ADD INDEX EdxTrackEventIdxCourseDisplayName (course_display_name(255)),
	    #   ADD INDEX EdxTrackEventIdxResourceDisplayName (resource_display_name(255)),
	    #   ADD INDEX EdxTrackEventIdxSuccess (success(15)),
	    #   ADD INDEX EdxTrackEventIdxTime (time),
	    #   ADD INDEX EdxTrackEventIdxIP (ip_country(3)),
	    #   ADD INDEX EdxTrackEventIdxCourseNameTime (course_display_name,time),
	    #   ADD INDEX EdxTrackEventIdxVideoId (video_id(255));
	    # COMMIT;"

	echo "Creating index on EdxTrackEvent(event_type) if needed..."
	mysql  -e "USE Edx; CALL createIndexIfNotExists('EdxTrackEventIdxEvType', 'EdxTrackEvent', 'event_type', 255);"
	echo "Creating index on EdxTrackEvent(anon_screen_name) if needed..."
	mysql  -e "USE Edx; CALL createIndexIfNotExists('EdxTrackEventIdxIdxUname', 'EdxTrackEvent', 'anon_screen_name', 40);"
	echo "Creating index on EdxTrackEvent(course_display_name) if needed..."
	mysql  -e "USE Edx; CALL createIndexIfNotExists('EdxTrackEventIdxCourseDisplayName', 'EdxTrackEvent', 'course_display_name', 255);"
	echo "Creating index on EdxTrackEvent(resource_display_name) if needed..."
	mysql  -e "USE Edx; CALL createIndexIfNotExists('EdxTrackEventIdxResourceDisplayName', 'EdxTrackEvent', 'resource_display_name', 255);"
	echo "Creating index on EdxTrackEvent(success) if needed..."
	mysql  -e "USE Edx; CALL createIndexIfNotExists('EdxTrackEventIdxSuccess', 'EdxTrackEvent', 'success', 15);"
	echo "Creating index on EdxTrackEvent(time) if needed..."
	mysql  -e "USE Edx; CALL createIndexIfNotExists('EdxTrackEventIdxTime', 'EdxTrackEvent', 'time', NULL);"
	echo "Creating index on EdxTrackEvent(quarter) if needed..."
	mysql  -e "USE Edx; CALL createIndexIfNotExists('EdxTrackEventIdxQuarter', 'EdxTrackEvent', 'quarter', NULL);"
	echo "Creating index on EdxTrackEvent(ip) if needed..."
	mysql  -e "USE Edx; CALL createIndexIfNotExists('EdxTrackEventIdxIP', 'EdxTrackEvent', 'ip_country', 3);"
	echo "Creating index on EdxTrackEvent(course_display_name,time) if needed..."
	mysql  -e "USE Edx; CALL createIndexIfNotExists('EdxTrackEventIdxCourseNameTime', 'EdxTrackEvent', 'course_display_name,time', NULL);"
	echo "Creating index on EdxTrackEvent(video_id) if needed..."
	mysql  -e "USE Edx; CALL createIndexIfNotExists('EdxTrackEventIdxVideoId', 'EdxTrackEvent', 'video_id', 255);"
	echo "Creating index on EdxTrackEvent(video_code) if needed..."
	mysql  -e "USE Edx; CALL createIndexIfNotExists('EdxTrackEventIdxVideoCode', 'EdxTrackEvent', 'video_code', 255);"

    elif [ $table == 'Answer' ]
    then
	echo "Creating index on Answer(answer) if needed..."
	mysql  -e "USE Edx; CALL createIndexIfNotExists('AnswerIdxAns', 'Answer', 'answer', 255);"
	echo "Creating index on Answer(course_id) if needed..."
	mysql  -e "USE Edx; CALL createIndexIfNotExists('AnswerIdxCourseID', 'Answer', 'course_id', 255);"

    elif [ $table == 'Account' ]
    then
	echo "Creating index on Account(screen_name) if needed..."
	mysql  -e "USE EdxPrivate; CALL createIndexIfNotExists('AccountIdxUname', 'Account', 'screen_name', 255);"
	echo "Creating index on Account(anon_screen_name) if needed..."
	mysql  -e "USE EdxPrivate; CALL createIndexIfNotExists('AccountIdxAnonUname', 'Account', 'anon_screen_name', 40);"
	echo "Creating index on Account(zipcode) if needed..."
	mysql  -e "USE EdxPrivate; CALL createIndexIfNotExists('AccountIdxZip', 'Account', 'zipcode', 10);"
	echo "Creating index on Account(country) if needed..."
	mysql  -e "USE EdxPrivate; CALL createIndexIfNotExists('AccountIdxCoun', 'Account', 'country', 255);"
	echo "Creating index on Account(gender) if needed..."
	mysql  -e "USE EdxPrivate; CALL createIndexIfNotExists('AccountIdxGen', 'Account', 'gender', 6);"
	echo "Creating index on Account(year_of_birth'..."
	mysql  -e "USE EdxPrivate; CALL createIndexIfNotExists('AccountIdxDOB', 'Account', 'year_of_birth', NULL);"
	echo "Creating index on Account(level_of_education) if needed..."
	mysql  -e "USE EdxPrivate; CALL createIndexIfNotExists('AccountIdxEdu', 'Account', 'level_of_education', 10);"
	echo "Creating index on Account(course_id) if needed..."
	mysql  -e "USE EdxPrivate; CALL createIndexIfNotExists('AccountIdxCouID', 'Account', 'course_id', 255);"

    elif [ $table == 'ActivityGrade' ]
    then
	echo "Creating index on ActivityGrade(first_submit) if needed..."
	mysql  -e "USE Edx; CALL createIndexIfNotExists('activityGradeFirst_submitIdx', 'ActivityGrade', 'first_submit', NULL);"
	echo "Creating index on ActivityGrade(last_submit) if needed..."
	mysql  -e "USE Edx; CALL createIndexIfNotExists('activityGradeLast_submitIdx', 'ActivityGrade', 'last_submit', NULL);"
	echo "Creating index on ActivityGrade(ActGrdAnonSNIdx) if needed..."
	mysql  -e "USE Edx; CALL createIndexIfNotExists('ActGrdAnonSNIdx', 'ActivityGrade', 'anon_screen_name', 40);"
	echo "Creating index on ActivityGrade(course_display_name) if needed..."
	mysql  -e "USE Edx; CALL createIndexIfNotExists('ActGrdCourseDisNmIdx', 'ActivityGrade', 'course_display_name', 255);"
	echo "Creating index on ActivityGrade(module_id) if needed..."
	mysql  -e "USE Edx; CALL createIndexIfNotExists('ActGrdModIdIdx', 'ActivityGrade', 'module_id', 255);"
	echo "Creating index on ActivityGrade(module_type) if needed..."
	mysql  -e "USE Edx; CALL createIndexIfNotExists('ActGrdModTypeIdx', 'ActivityGrade', 'module_type', 32);" #255
	echo "Creating index on ActivityGrade(resource_display_name) if needed..."
	mysql  -e "USE Edx; CALL createIndexIfNotExists('ActGrdResDispNmIdx', 'ActivityGrade', 'resource_display_name', 255);"
	echo "Creating index on ActivityGrade(num_attempts) if needed..."
	mysql  -e "USE Edx; CALL createIndexIfNotExists('ActGrdNumAttemptsIdx', 'ActivityGrade', 'num_attempts', NULL);"
    elif [ $table == 'ABExperiment' ]
    then
	echo "Creating index on ABExperiment(event_type) if needed..."
	mysql  -e "USE Edx; CALL createIndexIfNotExists('ABExpEventTypeIdx', 'ABExperiment', 'event_type', NULL);"
	echo "Creating index on ABExperiment(group_id) if needed..."
	mysql  -e "USE Edx; CALL createIndexIfNotExists('ABExpGrpIdIdx', 'ABExperiment', 'group_id', NULL);"
	echo "Creating index on ABExperiment(course_display_name) if needed..."
	mysql  -e "USE Edx; CALL createIndexIfNotExists('ABExpGrpNmIdx', 'ABExperiment', 'group_name', 255);"
	echo "Creating index on ABExperiment(module_id) if needed..."
	mysql  -e "USE Edx; CALL createIndexIfNotExists('ABExpPartIdIdx', 'ABExperiment', 'partition_id', NULL);"
	echo "Creating index on ABExperiment(resource_display_name) if needed..."
	mysql  -e "USE Edx; CALL createIndexIfNotExists('ABExpPartNmIdx', 'ABExperiment', 'partition_name', 255);"
	echo "Creating index on ABExperiment(num_attempts) if needed..."
	mysql  -e "USE Edx; CALL createIndexIfNotExists('ABExpChldModIdIdx', 'ABExperiment', 'child_module_id', 255);"

    elif [ $table == 'OpenAssessment' ]
    then
	echo "Creating index on OpenAssessment(event_type) if needed..."
	mysql  -e "USE Edx; CALL createIndexIfNotExists('OpAssEvTypeIdx', 'OpenAssessment', 'event_type', 255);"
	echo "Creating index on OpenAssessment(anon_screen_name) if needed..."
	mysql  -e "USE Edx; CALL createIndexIfNotExists('OpAssAnonScNmIdx', 'OpenAssessment', 'anon_screen_name', 40);"
	echo "Creating index on OpenAssessment(score_type) if needed..."
	mysql  -e "USE Edx; CALL createIndexIfNotExists('OpAssScoreTpIdx', 'OpenAssessment', 'score_type', 255);"
	echo "Creating index on OpenAssessment(time) if needed..."
	mysql  -e "USE Edx; CALL createIndexIfNotExists('OpAssTimeIdx', 'OpenAssessment', 'time', NULL);"
	echo "Creating index on OpenAssessment(submission_uuid) if needed..."
	mysql  -e "USE Edx; CALL createIndexIfNotExists('OpAssSubmIdIdx', 'OpenAssessment', 'submission_uuid', 40);"
	echo "Creating index on OpenAssessment(edx_anon_id) if needed..."
	mysql  -e "USE Edx; CALL createIndexIfNotExists('OpAssEdxAnonIdx', 'OpenAssessment', 'edx_anon_id', 40);"
	echo "Creating index on OpenAssessment(course_display_name) if needed..."
	mysql  -e "USE Edx; CALL createIndexIfNotExists('OpAssCrsNmIdx', 'OpenAssessment', 'course_display_name', 255);"
	echo "Creating index on OpenAssessment(resource_display_name) if needed..."
	mysql  -e "USE Edx; CALL createIndexIfNotExists('OpAssRrcDispNmIdx', 'OpenAssessment', 'resource_display_name', 255);"
	echo "Creating index on OpenAssessment(resource_id) if needed..."
	mysql  -e "USE Edx; CALL createIndexIfNotExists('OpAssRscIdIdx', 'OpenAssessment', 'resource_id', 255);"
	echo "Creating index on OpenAssessment(attempt_num) if needed..."
	mysql  -e "USE Edx; CALL createIndexIfNotExists('OpAssAttNumNmIdx', 'OpenAssessment', 'attempt_num', NULL);"
	echo "Creating index on OpenAssessment(options) if needed..."
	mysql  -e "USE Edx; CALL createIndexIfNotExists('OpAssOptsIdx', 'OpenAssessment', 'options', 255);"
	echo "Creating index on OpenAssessment(corrections) if needed..."
	mysql  -e "USE Edx; CALL createIndexIfNotExists('OpAssCorrIdx', 'OpenAssessment', 'corrections', 40);"
	echo "Creating index on OpenAssessment(points) if needed..."
	mysql  -e "USE Edx; CALL createIndexIfNotExists('OpAssPtsidx', 'OpenAssessment', 'points', 40);"

    elif [ $table == 'UserCountry' ]
    then
	echo "Creating index on UserCountry(anon_screen_name) if needed..."
	mysql  -e "USE Edx; CALL createIndexIfNotExists('UserCountryIdxAnon', 'UserCountry', 'anon_screen_name', 40);"
	echo "Creating index on UserCountry(three_letter_country) if needed..."
	mysql  -e "USE Edx; CALL createIndexIfNotExists('UserCountryIdx3LtrCntry', 'UserCountry', 'three_letter_country', 3);"
	echo "Creating index on UserCountry(two_letter_country) if needed..."
	mysql  -e "USE Edx; CALL createIndexIfNotExists('UserCountryIdx2LtrCntry', 'UserCountry', 'two_letter_country', 2);"
	echo "Creating index on UserCountry(country) if needed..."
	mysql  -e "USE Edx; CALL createIndexIfNotExists('UserCountryIdxCntry', 'UserCountry', 'country', 255);"

    fi
done

echo "Done creating indexes."

cd /home/ec2-user/dataman

echo -e "${COLOR}---Finished database configuration.---${COLOR_RST}"

#!/bin/bash

# parameter to acceppt location of war file to deploy  
WARPATH=$1
# parameter to accept container name of tomcat server
CONTAINER=$2

# Check for parameter 1 ( War file to deploy)
if [ '$WARPATH' == "" ]; then
	echo "please Check the script Usage .Usage ./webapp_deploy.sh <WAR_LOCATION>  <CONTAINNER_NAME>"
	exit 0
fi

# check for parameter 2 ( Container name )
if [ '$CONTAINER' == "" ]; then
	echo "please Check the script Usage .Usage ./webapp_deploy.sh <WAR_LOCATION> <CONTAINNER_NAME>"
	exit 0
fi
# check the war file exists, if exist copy file to tomcat cat deploy folder using docker cp command
if [ -e $WARPATH ]; then
	sudo docker cp $WARPATH $CONTAINER:/usr/local/tomcat/webapps
else
	echo 'War file not exits please check the path $WARPATH'
	exit 0
fi





 





#!/bin/bash

# Src of workflow mvn project
CODEPATH=$1
# Local maven repository where Maven install create Kjar 
LOCALREPO=$2
# JBPM Conatainer name 
CONTAINER=$3

# location of the Script
SCRIPTPATH=$PWD

# Checking for Parameter 1 - CODEPATH 
if [ '$CODEPATH' == "" ]; then
	echo "please Check the script Usage .Usage ./jbpm_deploy.sh <CODE_LOCATION> <LOCAL_MAVEN_REPO>  <CONTAINNER_NAME>"
	exit 0
fi
# Checking for Parameter 2 - LOCAL MAVEN REPO
if [ '$LOCALREPO' == "" ]; then
	echo "please Check the script Usage .Usage ./jbpm_deploy.sh <CODE_LOCATION> <LOCAL_MAVEN_REPO>  <CONTAINNER_NAME>"
	exit 0
fi

# Checking for Parameter 3  - JBPM Server Container name 
if [ -z "$CONTAINER" ]; then
       CONTAINER='jbpm-container'	
fi

echo $CONTAINER

# Getting Container IP for JBPM Docker Container
SERVERIP="$(sudo docker inspect -f '{{.NetworkSettings.IPAddress}}' $CONTAINER)"
# Getting Host Mount Directory for JBPM REPOSITORY
JBPMREPO="$(sudo docker inspect -f '{{range .Mounts}}{{if eq .Destination "/opt/jboss/wildfly/bin/repositories"}}{{.Source}}{{end}}{{end}}' $CONTAINER)"

# Checking for empty SERVER IP, Exit if ip is empty
if [ '$SERVERIP' == "" ]; then
	echo "Not able to retrieve SERVER IP FOR THE CONATINER provided,please Check Container name"
	exit 0
fi

# Checking for empty Mount Directory , exit if mount directory doesn't exist
if [ '$JBPMREPO' == "" ]; then
	echo "Not able to retrieve MOUNT detail for JBPMRESPOSITORY FOR THE CONATINER provided,please Check Container name and MOUNT SETUP"
	exit 0
fi

# Change to Code directory
cd $CODEPATH

GROUPID="$(mvn org.apache.maven.plugins:maven-help-plugin:2.2:evaluate -Dexpression=project.groupId |grep -Ev '(^\[|Download\w+:)' )"
# Extracting Artifact id from pom file  
ARTIFACTID="$(mvn org.apache.maven.plugins:maven-help-plugin:2.2:evaluate -Dexpression=project.artifactId |grep -Ev '(^\[|Download\w+:)')"
# Extracting Artifact Version from pom file  
ARTIFACTVER="$(mvn org.apache.maven.plugins:maven-help-plugin:2.2:evaluate -Dexpression=project.version |grep -Ev '(^\[|Download\w+:)')"
# creating Artifact directory from GROUPID and ARTIFACTID
ARTIFACTDIR="$(echo $GROUPID.$ARTIFACTID | awk '{gsub(/\./,"/");gsub(/\:/,"/")}1')"
ARTIFACT=$GROUPID:$ARTIFACTID:$ARTIFACTVER

echo $PWD
# mvn Install command to build , run test cases and install Artifacts into local Maven repository 
# creates Checksum and pom files for JBPM Validation of Artifact 
# if Build Success proceed else Quit 
mvn install -DcreateChecksum=true -Dmaven.repo.local=$LOCALREPO > $SCRIPTPATH/buildstatus.log

if grep "BUILD SUCCESS" $SCRIPTPATH/buildstatus.log > /dev/null
then
    echo "*****Build Success"
else
    echo "*****Build Failed Please check Build Status log"
    exit 0
fi

# Change to JBPM repo Mount Directory
sudo chown -R jboss:jboss $JBPMREPO
sudo chmod -R a+rw $JBPMREPO
cd $JBPMREPO/kie

# create Artifact directory in Mount Repo directory
sudo mkdir -p  $ARTIFACTDIR

# Copy Artifact to deploy from Local Maven repository to JBPM mount repo directory
sudo cp -R $LOCALREPO/$ARTIFACTDIR/* $JBPMREPO/kie/$ARTIFACTDIR
sudo chown -R jboss:jboss $JBPMREPO
sudo chmod -R a+rw $JBPMREPO

# Change to Script directory
cd $SCRIPTPATH

# Execute curl get rest command with Basic authorization  to check any previos deploymens match with artifct 
# if deployment exist Undeploy artifact from server 
curl -i -H "authorization: Basic a3Jpc3Y6a3Jpc3Y=" -H "Content-Type: application/xml" -H "Accept:application/json" -X GET http://$SERVERIP:8080/jbpm-console/rest/deployment/$ARTIFACT  > $SCRIPTPATH/deploystatus.log

UNDEPLOYED="false"

if grep \"status\":\"DEPLOYED\" $SCRIPTPATH/deploystatus.log 
    then
        echo "*****Deployment EXIST Undeploying"
        
    # rest call to Undeploy Artifact if already exist, Undeploy is asynchronous call, will take some time to undeploy. response is only for Acceptance, repose is not the status of the undeployment
    
        curl -i -H "authorization: Basic a3Jpc3Y6a3Jpc3Y=" -H "Content-Type: application/xml" -H "Accept:application/json" -X POST -d @descriptor.xml  http://$SERVERIP:8080/jbpm-console/rest/deployment/$ARTIFACT/undeploy > $SCRIPTPATH/undeploystatus.log

        if grep \"status\":\"ACCEPTED\" $SCRIPTPATH/undeploystatus.log 
        then
            echo "*****UnDeployment Package Accepted"
            
            for x in {1..8};
            do
                curl -i -H "authorization: Basic a3Jpc3Y6a3Jpc3Y=" -H "Content-Type: application/xml" -H "Accept:application/json" -X GET http://$SERVERIP:8080/jbpm-console/rest/deployment/$ARTIFACT >> $SCRIPTPATH/undeploystatus.log

                if grep \"status\":\"UNDEPLOYED\" $SCRIPTPATH/undeploystatus.log 
                then
                    echo "***** Successfully Undeployed"
                    UNDEPLOYED="true"
                    # delete Artifact from jboss .m2 directory.(workaround for jbpm issue of not deleting artifact from local maven home))
                    # Changing permissions on local Maven home directory 
                    sudo docker exec $CONTAINER chmod -R 777 /opt/jboss/.m2/repository/$ARTIFACTDIR
                    # Deleting artifact from local jboss Maven home. 
                    sudo docker exec $CONTAINER rm -rf /opt/jboss/.m2/repository/$ARTIFACTDIR
                    break
                else
                    for i in {1..15};
                    do
                       echo -n "."
                       sleep 1
                    done
                fi                
            done

            echo 'undeployed :'$UNDEPLOYED
            
             if [ $UNDEPLOYED == "false" ]; then
                echo "*****UnDeployment Failed Please check Build Status log"
             fi
             
        else
            echo "*****Package UnDeployment  Failed Please check undeploy Status log"
            exit 0
        fi
fi
    		
# remove temporary rest call status logs
if [ -e undeploystatus.log ]
then
rm -f undeploystatus.log
fi

# remove temporary rest call status logs
if [ -e deploystatus.log ]
then
rm -f deploystatus.log 
fi

# Rest call to submit artifact to deployment to JBPM SERVER
curl -i -H "authorization: Basic a3Jpc3Y6a3Jpc3Y=" -H "Content-Type: application/xml" -H "Accept:application/json" -X POST -d @descriptor.xml  http://$SERVERIP:8080/jbpm-console/rest/deployment/$ARTIFACT/deploy >> $SCRIPTPATH/buildstatus.log

# Checking Status of rest call, if it is accepted wait for deployment to finish
DEPLOYED="false"

if grep \"status\":\"ACCEPTED\" $SCRIPTPATH/buildstatus.log 
then
    echo "*****Deployment Package Accepted"
    
	for x in {1..8};
	do
        curl -i -H "authorization: Basic a3Jpc3Y6a3Jpc3Y=" -H "Content-Type: application/xml" -H "Accept:application/json" -X GET http://$SERVERIP:8080/jbpm-console/rest/deployment/$ARTIFACT > $SCRIPTPATH/deploystatus.log

        if grep \"status\":\"DEPLOYED\" $SCRIPTPATH/deploystatus.log
        then
            echo "*****Deployment Success"
            DEPLOYED="true"
            break
        else
            for i in {1..15};
            do
	           echo -n "."
	           sleep 1
            done
        fi

    done
    
    echo 'Deployed : '$DEPLOYED
    
     if [ $DEPLOYED == "false" ]; then
        echo "*****Deployment Failed Please check Build Status log"
        exit 0
     fi

else
    echo "*****Package Deployment  Failed Please check Build Status log"
    exit 0
fi

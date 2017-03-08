Docker images to install tomcat 9.  
Tomcat is customised to access Manager admin screens


Prerequisite 
* docker

Installation:

1. Get a local clone of the repo. Run the following command from workflow/docker_tomcat to build tomcat image with customised user setup 

   * sudo docker build -t tomcat:9.0 .

2. Run container with image tomcat:9.0 
   * sudo docker run -p 8888:8080  -dit --name tomcat-container  tomcat:9.0
   
   * Once installed, tomacat server should be accessible from https://localhost:8888   


3. deploy any web application as WAR file using webapp-deploy.sh

   * ./webapp-deploy.sh [WAR FILE LOCATION] 
   
   * The deployed apps can be accessed from https://localhost:8888 Manager App with admin:secret.

	

   
   

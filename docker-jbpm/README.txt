Docker images to install JBPM 6 on a clean wildfly app server.  
JBPM is customized to intergrate with either in-memory H2 DB or MySQL DB.


Prerequisite 
* docker
* git

Installation:

1. Clone workflow git repo
2. Enter directory docker in local workflow repo 
3. Run the following command to build jbpm image
   sudo docker build -t jbpm .

Install JBPM with H2 DB:
   docker run -p 8080:8080 -p 8081:8081 -p 9990:9990 -it --name jbpm-container -d jbpm

Install JBPM with MySQL DB:

4. Install MysQL server
   sudo docker run --name mysql-container -e MYSQL_ROOT_PASSWORD=root -e MYSQL_DATABASE=jbpm -d mysql
5. Install JBPM 
   docker run -p 8080:8080 -p 8081:8081 --link mysql-container:MYSQL -it --name jbpm-container -d jbpm

If you want to mount jbpm Maven repository to Host directory for CI/CD

6. sudo docker run -p 8080:8080 -p 8081:8081 -p 9990:9990 --link mysql-container:MYSQL -it -v /home/jboss/docker/repositories:/opt/jboss/wildfly/bin/repositories  --name jbpm-container -d jbpm
   
Once installed, go to https://localhost:8080/jbpm-console and log in with admin:admin.   
   
   

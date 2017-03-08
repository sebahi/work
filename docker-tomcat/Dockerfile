FROM tomcat:9.0-jre8

# add users and roles
ADD tomcat-users.xml /usr/local/tomcat/conf/

# add file to enable remote access to manager app
ADD context.xml /usr/local/tomcat/webapps/manager/META-INF/context.xml
ADD context.xml /usr/local/tomcat/webapps/host-manager/META-INF/context.xml






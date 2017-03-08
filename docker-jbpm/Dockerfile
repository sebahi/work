####### BASE ############
FROM jboss/wildfly:10.0.0.Final

####### LOCALE ############
ENV LANG en_US.UTF-8

####### ENVIRONMENT ############
ENV JAVA_OPTS -Xms512m -Xmx1024m
ENV JBOSS_BIND_ADDRESS 0.0.0.0
ENV KIE_CONNECTION_URL jdbc:h2:mem:test;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE
ENV KIE_CONNECTION_DRIVER h2
ENV KIE_CONNECTION_USER sa
ENV KIE_CONNECTION_PASSWORD sa
ENV KIE_CONNECTION_DATABASE jbpm 
ENV KIE_REPOSITORY https://repository.jboss.org/nexus/content/groups/public-jboss
ENV KIE_VERSION 6.5.0.Final
ENV KIE_CLASSIFIER wildfly10
ENV KIE_CONTEXT_PATH jbpm-console 
ENV DASHBUILDER_CONTEXT_PATH dashbuilder
# Do NOT use demo examples by default in this image (no internet connection required).
ENV KIE_DEMO false
ENV KIE_SERVER_PROFILE standalone-full
ENV MYSQL_DRIVER_VERSION 5.1.18

####### SYTEM USERS FOR DEVELOPMENT ############
USER root
# Set a password for root & jboss users (for any further system operations, etc)
RUN echo "root:rootman" | chpasswd && \
echo "jboss:jboss" | chpasswd

####### KIE-WB & WILDFLY 10 CONFIG FILES ############
# Latest WAR from Maven repository & Custom WildFly configuration files
# There is an issue in Docker with ADD command.
# When a file is added into the container's filesystem, the file owner is always root, instead of the current running user.
# See https://github.com/docker/docker/issues/5110
# The workaround is doing a chown using root user and then switchback to jboss user.

# WildFly custom configuration.
ADD etc/kie-wb-users.properties $JBOSS_HOME/standalone/configuration/kie-wb-users.properties
ADD etc/kie-wb-roles.properties $JBOSS_HOME/standalone/configuration/kie-wb-roles.properties
ADD etc/standalone-full-kie-wb.xml $JBOSS_HOME/standalone/configuration/standalone-full-kie-wb.xml

# Wildfly Admin users
ADD etc/mgmt-users.properties $JBOSS_HOME/standalone/configuration/mgmt-users.properties
ADD etc/mgmt-groups.properties $JBOSS_HOME/standalone/configuration/mgmt-groups.properties


# Custom kie-wb WildFly startup scripts.
ADD etc/start_kie-wb.sh $JBOSS_HOME/bin/start_kie-wb.sh
ADD etc/update-jpa-config.sh $JBOSS_HOME/bin/update-jpa-config.sh

####### JBPM-WB ############
RUN curl -o $HOME/$KIE_CONTEXT_PATH.war $KIE_REPOSITORY/org/kie/kie-wb-distribution-wars/$KIE_VERSION/kie-wb-distribution-wars-$KIE_VERSION-$KIE_CLASSIFIER.war && \
unzip -q $HOME/$KIE_CONTEXT_PATH.war -d $JBOSS_HOME/standalone/deployments/$KIE_CONTEXT_PATH.war &&  \
touch $JBOSS_HOME/standalone/deployments/$KIE_CONTEXT_PATH.war.dodeploy &&  \ 
rm -rf $HOME/$KIE_CONTEXT_PATH.war

####### JBPM DASHBUILDER ############
RUN curl -o $HOME/$DASHBUILDER_CONTEXT_PATH.war $KIE_REPOSITORY/org/jbpm/dashboard/jbpm-dashboard-distributions/$KIE_VERSION/jbpm-dashboard-distributions-$KIE_VERSION-$KIE_CLASSIFIER.war && \
unzip -q $HOME/$DASHBUILDER_CONTEXT_PATH.war -d $JBOSS_HOME/standalone/deployments/$DASHBUILDER_CONTEXT_PATH.war &&  \
touch $JBOSS_HOME/standalone/deployments/$DASHBUILDER_CONTEXT_PATH.war.dodeploy &&  \ 
rm -rf $HOME/$DASHBUILDER_CONTEXT_PATH.war

####### MVN REPO ############
# https://bugzilla.redhat.com/show_bug.cgi?id=1263738
RUN mkdir -p $HOME/.m2/repository/org/guvnor/guvnor-asset-mgmt-project/$KIE_VERSION && \
curl -o $HOME/.m2/repository/org/guvnor/guvnor-asset-mgmt-project/$KIE_VERSION/guvnor-asset-mgmt-project-$KIE_VERSION.jar $KIE_REPOSITORY/org/guvnor/guvnor-asset-mgmt-project/$KIE_VERSION/guvnor-asset-mgmt-project-$KIE_VERSION.jar

# Database MySQL modules
RUN curl -o $HOME/mysql-connector-java.jar https://repository.jboss.org/nexus/service/local/repositories/central/content/mysql/mysql-connector-java/$MYSQL_DRIVER_VERSION/mysql-connector-java-$MYSQL_DRIVER_VERSION.jar && \
mkdir -p $JBOSS_HOME/modules/system/layers/base/com/mysql/main/ && \
cp $HOME/mysql-connector-java.jar $JBOSS_HOME/modules/system/layers/base/com/mysql/main/ && \
rm -rf $HOME/mysql-connector-java.jar 

ADD etc/mysql_module.xml $JBOSS_HOME/modules/system/layers/base/com/mysql/main/module.xml 

# Set right permissions for jboss user.
RUN chown -R jboss:jboss $JBOSS_HOME/standalone/deployments/* && \
chmod +x $JBOSS_HOME/bin/*.sh && \
chown jboss:jboss $JBOSS_HOME/bin/start_kie-wb.sh && \
chown jboss:jboss $JBOSS_HOME/bin/update-jpa-config.sh && \
chown jboss:jboss $JBOSS_HOME/standalone/configuration/kie-wb-users.properties && \ 
chown jboss:jboss $JBOSS_HOME/standalone/configuration/kie-wb-roles.properties && \
chown jboss:jboss $JBOSS_HOME/standalone/configuration/mgmt-users.properties && \ 
chown jboss:jboss $JBOSS_HOME/standalone/configuration/mgmt-groups.properties && \
chown jboss:jboss $JBOSS_HOME/standalone/configuration/standalone-full-kie-wb.xml && \
chown -R jboss:jboss $JBOSS_HOME/modules/system/layers/base/*



# Switchback to jboss user
USER jboss

 




####### EXPOSE INTERNAL KIE-WB GIT PORT ############
EXPOSE 8001

####### COMMAND ############
WORKDIR $JBOSS_HOME/bin/
CMD ["./start_kie-wb.sh"]

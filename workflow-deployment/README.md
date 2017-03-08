README -  Workflow Deployment Script

 * Script builds and creates artifact for JBPM Maven project
 * verifies Artifacts
 * verifies the existing deployments on container for previous deployments. Undeploys artifact if previous deployments exist fro the artifact
 * copies artifact to JBPM mvn Repository
 * deploys JBPM workflow Artifact to server using Rest API and verifies deployment
 
Execution:
 * ./deploy.sh [WORKFLOW_MAVEN_PROJECT_LOCATION] [LOCAL_MAVEN_REPO_LOCATION] [JBPM_CONTAINNER_NAME]
 
Required parameters:
 * [WORKFLOW_MAVEN_PROJECT_LOCATION] - workflow maven project folder path 
 * [LOCAL_MAVEN_REPO_LOCATION] - Local Maven repository folder path

Optional parameter:
 * [JBPM_CONTAINNER_NAME] - JBPM server Container name

Example:
 * ./deploy.sh ../workflow ~/.m2/repository  


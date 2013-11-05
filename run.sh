#!/bin/sh
set -e

#VARIABLE Checking
if [ -z "$WERCKER_TOMCAT_DEPLOY_DEPLOY_HOST" ]; then
    fail 'missing "DEPLOY_HOST" option, please add it in your wercker.yml'
fi

USER="ubuntu"
if [ -n "$WERCKER_TOMCAT_DEPLOY_USER" ]; then
    USER=$WERCKER_TOMCAT_DEPLOY_USER	
fi

if [ -z "$WERCKER_TOMCAT_DEPLOY_SSHKEY" ]; then
    fail 'missing "sshkey" option, please add it in your wercker.yml'
fi

if [ -z "$WERCKER_TOMCAT_DEPLOY_CONTEXT_DESCRIPTOR_FILE" ]; then
    fail 'missing "context_descriptor_file" option, please add it in your wercker.yml'
fi

if [ -z "$WERCKER_TOMCAT_DEPLOY_WAR_FILE_DESTINATION" ]; then
    fail 'missing "war_file_destination" option, please add it in your wercker.yml'
fi

if [ -z "$WERCKER_TOMCAT_DEPLOY_WAR_FILE_SOURCE" ]; then
    fail 'missing "war_file_source" option, please add it in your wercker.yml'
fi

if [ -z "$WERCKER_TOMCAT_DEPLOY_SERVLET_PATH" ]; then
    fail 'missing "war_file_source" option, please add it in your wercker.yml'
fi

SERVICE_NAME="tomcat7"
if [ -n "$WERCKER_TOMCAT_DEPLOY_SERVICE_NAME" ]; then
	SERVICE_NAME=$WERCKER_TOMCAT_DEPLOY_SERVICENAME
fi


#first deploy the (new) file
deploy_path=`basename $WERCKER_TOMCAT_DEPLOY_CONTEXT_DESCRIPTOR_FILE`
tmp_context_file=/tmp/`basename $WERCKER_TOMCAT_DEPLOY_CONTEXT_DESCRIPTOR_FILE`

#create context file
cat << EOF > $tmp_context_file	
<Context docBase="$WERCKER_TOMCAT_DEPLOY_WAR_FILE_DESTINATION" path="$WERCKER_TOMCAT_DEPLOY_SERVLET_PATH" antiResourceLocking="false" reloadable="true" crossContext="true" allowLinking="true">
	<Environment name="appEnvironment" value="$ENVIRONMENT" type="java.lang.String" override="false"/>
</Context>
EOF

info 'generated contect file locally';

#copy the contextfile to the tomcat-server
info "cmd : scp -i ${WERCKER_TOMCAT_DEPLOY_SSHKEY} $tmp_context_file ${USER}@${WERCKER_TOMCAT_DEPLOY_HOST:${WERCKER_TOMCAT_DEPLOY_CONTEXT_DESCRIPTOR_FILE}";

result=$(scp -i ${WERCKER_TOMCAT_DEPLOY_SSHKEY} $tmp_context_file ${USER}@${WERCKER_TOMCAT_DEPLOY_HOST}:${WERCKER_TOMCAT_DEPLOY_CONTEXT_DESCRIPTOR_FILE})
if [[ $? -ne 0 ]]; then
    warning '$result'
    fail 'context file copy failed';
else
    info 'copied context file to server';
fi


info 'target: scp -i ${WERCKER_TOMCAT_DEPLOY_SSHKEY} $WERCKER_TOMCAT_DEPLOY_WAR_FILE_SOURCE ${USER}@${WERCKER_TOMCAT_DEPLOY_HOST}:${WERCKER_TOMCAT_DEPLOY_WAR_FILE_DESTINATION}';

result=$(scp -i ${WERCKER_TOMCAT_DEPLOY_SSHKEY} $WERCKER_TOMCAT_DEPLOY_WAR_FILE_SOURCE ${USER}@${WERCKER_TOMCAT_DEPLOY_HOST}:${WERCKER_TOMCAT_DEPLOY_WAR_FILE_DESTINATION})
if [[ $? -ne 0 ]]; then
    warning '$result'
    fail 'Failed to copy warfile to server';
else
    info 'copied war to server';
fi

result=$(ssh ${USER}@${WERCKER_TOMCAT_DEPLOY_HOST} -i ${WERCKER_TOMCAT_DEPLOY_SSHKEY} "sudo service $SERVICE_NAME restart")
if [[ $? -ne 0 ]]; then
    warning '$result'
    fail 'Failed to restart tomcat';
else
    copied 'restarted tomcat service';
fi


#!/bin/sh
set -e

#defaults
remote_user="ubuntu"
service_name="tomcat7"

#VARIABLE Checking
if [ -z "$WERCKER_TOMCAT_DEPLOY_HOST" ]; then
    fail 'missing "host" option, please add it in your wercker.yml'
fi

if [ -n "$WERCKER_TOMCAT_DEPLOY_USER" ]; then
    remote_user=$WERCKER_TOMCAT_DEPLOY_USER
fi

if [ -z "$WERCKER_TOMCAT_DEPLOY_SSHKEY" ]; then
    fail 'missing "sshkey" option, please add it in your wercker.yml'
fi

if [ -z "$WERCKER_TOMCAT_DEPLOY_WAR_FILE_SOURCE" ]; then
    fail 'missing "war_file_source" option, please add it in your wercker.yml'
fi

if [ -z "$WERCKER_TOMCAT_DEPLOY_WAR_FILE_DESTINATION" ]; then
    fail 'missing "war_file_destination" option, please add it in your wercker.yml'
fi

if [ -z "$WERCKER_TOMCAT_DEPLOY_CONTEXT_DESCRIPTOR_FILE" ]; then
    fail 'missing "context_descriptor_file" option, please add it in your wercker.yml'
fi

if [ -z "$WERCKER_TOMCAT_DEPLOY_SERVLET_PATH" ]; then
    fail 'missing "war_file_source" option, please add it in your wercker.yml'
fi

if [ -n "$WERCKER_TOMCAT_DEPLOY_SERVICE_NAME" ]; then
	service_name=$WERCKER_TOMCAT_DEPLOY_SERVICE_NAME
fi

#remapping names
host=$WERCKER_TOMCAT_DEPLOY_HOST
key=$WERCKER_TOMCAT_DEPLOY_SSHKEY
war_src=$WERCKER_TOMCAT_DEPLOY_WAR_FILE_SOURCE
war_dst=$WERCKER_TOMCAT_DEPLOY_WAR_FILE_DESTINATION
ctx_file=$WERCKER_TOMCAT_DEPLOY_CONTEXT_DESCRIPTOR_FILE
srvlet_path=$WERCKER_TOMCAT_DEPLOY_SERVLET_PATH

tmp_file_name_war="WERCKERFILE-war"
tmp_file_name_ctx="WERCKERFILE-war"

#first deploy the (new) file
deploy_path=`basename $ctx_file`
tmp_context_file=/tmp/`basename $deploy_path`

#create context file
cat << EOF > $tmp_context_file	
<Context docBase="$war_dst" path="$srvlet_path" antiResourceLocking="false" 
    reloadable="true" crossContext="true" allowLinking="true">
	<Environment name="appEnvironment" value="$ENVIRONMENT" type="java.lang.String" override="false"/>
</Context>
EOF

info 'generated context file locally';

#
#
#   Copying files in $home on remote server
#

#copy the contextfile to the tomcat-server
result=$(scp -i "$key" "$tmp_context_file" "$remote_user@$host:~/${tmp_file_name_ctx}" )
if [[ $? -ne 0 ]]; then
    warning '$result'
    fail 'context file copy failed';
else
    info 'copied context file to server';
fi

#copy the war file to the tomcat-server
result=$(scp -i "$key" "$war_src"  "$remote_user@$host:~/${tmp_file_name_war}" )
if [[ $? -ne 0 ]]; then
    warning '$result'
    fail 'Failed to copy warfile to server';
else
    info 'copied war to server';
fi

#
#
#   Moving files on destination servers (as result of sudo and scp)
#


#Move the CONTEXT file on the remote file to the proper location using sudo
result=$(ssh "$remote_user@$host" -i "$key" "sudo mv ~/${tmp_file_name_ctx} $ctx_file" )
if [[ $? -ne 0 ]]; then
    warning '$result'
    fail 'Failed to move context in right location';
else
    info 'Moved context in right location';
fi


#Move the war file on the remote file to the proper location using sudo
result=$(ssh "$remote_user@$host" -i "$key" "sudo mv ~/${tmp_file_name_war} $war_dst" )
if [[ $? -ne 0 ]]; then
    warning '$result'
    fail 'Failed more war file in right location';
else
    info 'moved war in right location';
fi



#
#   
#   trigger restart tomcat
#

result=$(ssh "$remote_user@$host" -i "$key" "sudo service $service_name restart")
if [[ $? -ne 0 ]]; then
    warning '$result'
    fail 'Failed to restart $service_name';
else
    info 'restarted $service_name service';
fi

info 'completed sucessfully :)'


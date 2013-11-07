#!/bin/bash
#
#	Example test file, will ONLY work on my machine :)
#
export WERCKER_TOMCAT_DEPLOY_HOST="test.example.org"
export WERCKER_TOMCAT_DEPLOY_SSHKEY="$HOME/.ssh/test.pem"
export WERCKER_TOMCAT_DEPLOY_WAR_FILE_SOURCE="/tmp/in"
export WERCKER_TOMCAT_DEPLOY_WAR_FILE_DESTINATION="/tmp/asdf"
export WERCKER_TOMCAT_DEPLOY_CONTEXT_DESCRIPTOR_FILE="/tmp/asdf"
export WERCKER_TOMCAT_DEPLOY_SERVLET_PATH="/temp"
export WERCKER_TOMCAT_DEPLOY_SERVICE_NAME="tomcat7"

function info {
	echo "info: $1"
}

function warning {
	echo "warning: $1"
}

function fail {
	echo "Failing with: $1"
	exit 1
}

source "./run.sh"

RESULT=$?
if [[ $RESULT != "0" ]] || [[ $GENERATED_BUILD_NR != "1" ]]; then
    echo "Test: FAIL -> $RESULT"
    return 1 2>/dev/null || exit 1
else
	echo "done"
fi
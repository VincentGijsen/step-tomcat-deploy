step-tomcat-deploy
==================

This step deploy's a war file to tomcat, and restarts tomcat

This is only tested on ubuntu-server 12.04 installation

# Assumptions:
* autoDeploy is enabled (default tomcat behaviour)
* Both context dir and deploy dir exists and are writable by `deploy_user`


# Options
* deploy_host The host running tomcat/sshd
* deploy_user (optional) The user (with sudo rights)
* sshkey the ssh key used to authenticate as `deploy user`
* war_file_source the path where to find the war-file (eg, after your build in target/)
* war_file_destination where to deploy the war-file
* context_descriptor_file the file used by tomcat to deploy the war under path `servlet_path`
* service_name (optional) on ubuntu usually 'tomact7' (Default)
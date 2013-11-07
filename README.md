step-tomcat-deploy
==================

Deploy a war file to tomcat, create context.xml and restarts tomcat

# Assumptions:
* autoDeploy is enabled (default tomcat behaviour)
* Both context dir and deploy dir exists and are writable by `deploy_user`
* This is only tested on ubuntu-server 12.04 installation


# Options
* `deploy_host` The host running tomcat/sshd
* `deploy_user` _(optional)_ The user (with sudo rights)
* `sshkey` the ssh key used to authenticate as `deploy user`
* `war_file_source` the path where to find the war-file (eg, after your build in target/)
* `war_file_destination` where to deploy the war-file
* `context_descriptor_file` the file used by tomcat to deploy the war under path `servlet_path`
* `service_name` _(optional)_ on ubuntu usually 'tomcat7' (Default)
* `servlet_path` path to bootstrap root of war

# Example
```yaml
- vinietje/tomcat-deploy :
        host: $HOST
        sshkey: $PRIVATEKEY_PATH
        war_file_source: $WAR_SRC
        war_file_destination: $WAR_DST
        context_descriptor_file: $CONTEXT_DESCRIPTOR_DST
        servlet_path: $WAR_PATH
```
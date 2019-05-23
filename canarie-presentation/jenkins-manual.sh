#!/bin/sh

echo "
Starting a new Jenkins server
**without** Jenkins Config as Code:
"
sleep 2

set -x
docker volume create jenkins0_home
docker run --name jenkins0 --detach --hostname jenkins0 -p 10080:8080 -v jenkins0_home:/var/jenkins_home jenkins/jenkins:lts
sleep 10
docker exec jenkins0 bash -c 'echo admin_pass=`cat $JENKINS_HOME/secrets/initialAdminPassword`'
set +x

echo "curl http://localhost:10080 to test



Have to install each plugins manually.

Have to set each config manually. :(

Have to configure each job manually !
"

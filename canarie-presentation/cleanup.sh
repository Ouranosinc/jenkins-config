#!/bin/sh

cd ..

set -x

# clean vanilla Jenkins
docker stop jenkins0
docker rm -v jenkins0
docker volume rm jenkins0_home

# clean up JCasC Jenkins
./jenkins-compose.sh down -v
docker volume rm jenkins_master_home_10090 jenkins_slave_home_10090
rm -v id_rsa_jenkins_demo id_rsa_jenkins_demo.pub

#!/bin/sh

echo "
Starting a new Jenkins server
**using** Jenkins Config as Code:
"
sleep 2
cd ..

set -x
ssh-keygen -t rsa -f id_rsa_jenkins_demo
cp env.local.example env.local
cat <<OEF >> env.local
# override default config
export JENKINS_HOSTNAME=localhost
export JENKINS_MASTER_PORT=10090
export SSH_PRIVATE_KEY="\`cat id_rsa_jenkins_demo\`"
export JENKINS_SLAVE_SSH_PUBKEY="\`cat id_rsa_jenkins_demo.pub\`"
OEF
./jenkins-compose.sh up -d
set +x

. ./env.local

echo "curl ${JENKINS_HTTP_PROTO}://${JENKINS_HOSTNAME}:${JENKINS_MASTER_PORT} to test



All plugins pre-installed.

All configs pre-configured.

All jobs pre-configured, just start a build.
"

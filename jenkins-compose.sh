#!/bin/bash

YELLOW=$(tput setaf 3)
RED=$(tput setaf 1)
NORMAL=$(tput sgr0)

# list of all variables to be substituted in templates
VARS='$JENKINS_MASTER_PORT $SSH_PRIVATE_KEY $JENKINS_ADMIN_PASSWD $JENKINS_HTTP_PROTO $JENKINS_HOSTNAME $JENKINS_SLAVE_SSH_PUBKEY $JENKINS_NUM_EXECUTORS_LOCAL $JCASC_DIR'

export DOCKER_GROUP_ON_HOST="`getent group |grep docker: | awk -F: '{print $3}'`"

# we switch to the real directory of the script, so it still works when used from $PATH
# tip: ln -s /path/to/pavics-compose.sh ~/bin/
cd $(dirname $(readlink -f $0 || realpath $0))

# we source local configs, if present
# we don't use usual .env filename, because docker-compose uses it
[[ -f env.local ]] && source env.local

for i in $VARS
do
  v="${i#$}"
  if [[ -z "${!v}" ]]
  then
    echo "${RED}Error${NORMAL}: Required variable $v is not set. Check env.local file."
    exit
  fi
done

if [[ ! -f docker-compose.yml ]]
then
  echo "Error, this script must be ran from the folder containing the docker-compose.yml file"
  exit 1
fi

if [[ $1 == "up" || $1 == "restart" ]]; then
  # create CASC_JENKINS_CONFIG
  CASC_JENKINS_CONFIG=buildout/jcasc_config
  rm -vrf $CASC_JENKINS_CONFIG
  mkdir -p $CASC_JENKINS_CONFIG
  cp -v $JCASC_DIR/*.yaml $CASC_JENKINS_CONFIG/
  for adir in $JCASC_EXTRA_DIRS; do
    # latest dir has highest precedence
    if [ -d "$adir" ]; then
      cp -v $adir/*.yaml $CASC_JENKINS_CONFIG/
    else
      echo "${YELLOW}Warn${NORMAL}: JCASC extra dir '$adir' do not exist."
    fi
  done
fi

if [ -z "$JENKINS_IS_PROD" ]; then
  export JENKINS_IS_PROD="false"
fi

if [ -z "$JENKINS_ENABLE_SCHEDULED_TRIGGER" ]; then
  export JENKINS_ENABLE_SCHEDULED_TRIGGER="false"
fi

# we apply all the templates
#find . -name '*.template' -print0 |
#  while IFS= read -r -d $'\0' FILE
#  do
#    DEST=${FILE%.template}
#    cat $FILE | envsubst "$VARS" > $DEST
#  done

# create volume outside of docker-compose.yml to prevent
# `docker-compose down -v` to delete the volume.
# if volume already exist, this call will do nothing
if [[ $1 == "up" ]]; then
  docker volume create jenkins_master_home_$JENKINS_MASTER_PORT
  docker volume create jenkins_slave_home_$JENKINS_MASTER_PORT
fi

docker-compose "$@"
ERR=$?

# execute post-compose function if exists and no error occurred
type post-compose 2>&1 | grep 'post-compose is a function' > /dev/null
if [[ $? -eq 0 ]]
then
  [[ $ERR -gt 0 ]] && { echo "Error occurred with docker-compose, not running post-compose"; exit $?; }
  post-compose "$@"
fi

# vi: tabstop=8 expandtab shiftwidth=2 softtabstop=2

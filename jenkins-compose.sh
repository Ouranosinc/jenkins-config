#!/usr/bin/env bash

YELLOW=$(tput setaf 3)
RED=$(tput setaf 1)
BLUE=$(tput setaf 4)
NORMAL=$(tput sgr0)

ERROR="${RED}ERROR${NORMAL}"
WARN="${YELLOW}WARN${NORMAL}"
INFO="${BLUE}INFO${NORMAL}"

# list of all variables to be substituted in templates
VARS='
  $JENKINS_MASTER_IMAGE
  $JENKINS_MASTER_PORT
  $SSH_PRIVATE_KEY
  $JENKINS_ADMIN_PASSWD
  $JENKINS_HTTP_PROTO
  $JENKINS_HOSTNAME
  $JENKINS_SSH_SLAVE_IMAGE
  $JENKINS_SSH_SLAVE_PUBKEY
  $JENKINS_NUM_EXECUTORS_LOCAL
  $JCASC_DIR
'

# we switch to the real directory of the script, so it still works when used from $PATH
# tip: ln -s /path/to/pavics-compose.sh ~/bin/
cd $(dirname $(readlink -f $0 || realpath $0))

# we source local configs, if present
# we don't use usual .env filename, because docker-compose uses it
[[ -f env.local ]] && source env.local

############################################################################
# Handle deprecated/backward-compatible and default variables
############################################################################

# warning: always make sure to self-reference the variable before to allow sourcing with overrides

# note: the 'SSH' and 'SLAVE' are purposely swapped below to match the legacy name
export JENKINS_SLAVE_SSH_PUBKEY=${JENKINS_SLAVE_SSH_PUBKEY:-${JENKINS_SSH_AGENT_PUBKEY}}
export JENKINS_SSH_SLAVE_PUBKEY=${JENKINS_SSH_SLAVE_PUBKEY:-${JENKINS_SLAVE_SSH_PUBKEY}}

# new variables for convenience/alignment of older 'ssh-slave' naming
# note: for legacy reasons, the '..._SSH_SLAVE_...' names can also be used
export JENKINS_SSH_AGENT_VERSION=${JENKINS_SSH_AGENT_VERSION:-${JENKINS_SSH_SLAVE_VERSION}}
export JENKINS_SSH_AGENT_DOCKER=${JENKINS_SSH_AGENT_DOCKER:-${JENKINS_SSH_SLAVE_DOCKER}}
export JENKINS_SSH_AGENT_IMAGE=${JENKINS_SSH_AGENT_IMAGE:-${JENKINS_SSH_SLAVE_IMAGE}}

# use "ssh-slave" repository to push in same location as older versions
export JENKINS_SSH_SLAVE_DOCKER=${JENKINS_SSH_AGENT_DOCKER:-pavics/jenkins-ssh-slave}
export JENKINS_SSH_SLAVE_VERSION=${JENKINS_SSH_AGENT_VERSION:-251211}
export JENKINS_SSH_SLAVE_IMAGE=${JENKINS_SSH_AGENT_IMAGE:-"${JENKINS_SSH_SLAVE_DOCKER}:${JENKINS_SSH_SLAVE_VERSION}"}

export JENKINS_MASTER_DOCKER=${JENKINS_MASTER_DOCKER:-pavics/jenkins-master}
export JENKINS_MASTER_VERSION=${JENKINS_MASTER_VERSION:-2.528.3.251211}
export JENKINS_MASTER_IMAGE=${JENKINS_MASTER_IMAGE:-"${JENKINS_MASTER_DOCKER}:${JENKINS_MASTER_VERSION}"}

############################################################################
# Validate required variables and set extra options
############################################################################

for i in $VARS
do
  v="${i#$}"
  if [[ -z "${!v}" ]]
  then
    echo "${ERROR}: Required variable $v is not set. Check env.local file."
    exit
  fi
done

if [[ ! -f docker-compose.yml ]]
then
  echo "${ERROR}: this script must be ran from the folder containing the docker-compose.yml file"
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
      echo "${WARN}: JCASC extra dir '$adir' do not exist."
    fi
  done
fi

if [ -z "$JENKINS_IS_PROD" ]; then
  export JENKINS_IS_PROD="false"
fi

if [ -z "$JENKINS_ENABLE_SCHEDULED_TRIGGER" ]; then
  export JENKINS_ENABLE_SCHEDULED_TRIGGER="false"
fi

if [ -z "$JENKINS_DEFAULT_PAVICS_HOST" ]; then
  export JENKINS_DEFAULT_PAVICS_HOST="pavics.ouranos.ca"
fi

# we apply all the templates
#find . -name '*.template' -print0 |
#  while IFS= read -r -d $'\0' FILE
#  do
#    DEST=${FILE%.template}
#    cat $FILE | envsubst "$VARS" > $DEST
#  done

set -x  # Log command
# create volume outside of docker-compose.yml to prevent
# `docker-compose down -v` to delete the volume.
# if volume already exist, this call will do nothing
if [[ $1 == "up" ]]; then
  docker volume create jenkins_master_home_$JENKINS_MASTER_PORT
  docker volume create jenkins_slave_home_$JENKINS_MASTER_PORT
fi

${JENKINS_COMPOSE_BIN:=docker compose} "$@"
ERR=$?
set +x

# execute post-compose function if exists and no error occurred
type post-compose 2>&1 | grep 'post-compose is a function' > /dev/null
if [[ $? -eq 0 ]]
then
  [[ $ERR -gt 0 ]] && { echo "${ERROR}: occurred with docker-compose, not running post-compose"; exit $?; }
  post-compose "$@"
fi

# vi: tabstop=8 expandtab shiftwidth=2 softtabstop=2

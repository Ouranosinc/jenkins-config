# jenkins-config
Jenkins deployment configurations.

## Usage

One time setup
```
ssh-keygen -t rsa -f ../my-cert/id_rsa_jenkins
cp env.local.example env.local
$EDITOR env.local  # customize to your needs
```

Start Jenkins master and slave
```
./jenkins-compose.sh up -d
```

Access Jenkins at
${JENKINS_HTTP_PROTO}://${JENKINS_HOSTNAME}:${JENKINS_MASTER_PORT},
those variables are from your customized `env.local` file.

`jenkins-compose.sh` is just a wrapper around `docker-compose` so all valid
docker-compose use-cases and command-line options are supported.

Upgrade instructions
```
./jenkins-compose.sh down -v  # only delete anonymous data volume
git pull
./jenkins-compose.sh up -d
```

## Data Persistance

This deployment uses named docker volume for data persistance.  Two named
volume will be created and will survive `./jenkins-compose.sh down -v`:

* jenkins_master_home_$JENKINS_MASTER_PORT
* jenkins_slave_home_$JENKINS_MASTER_PORT

The jenkins_master_home one is important as it contains build history, logs and
user passwords.

The jenkins_slave_home only contains the workspaces where the build occurred.

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

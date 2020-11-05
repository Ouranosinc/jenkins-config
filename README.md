# jenkins-config
Jenkins deployment configuration, fully pre-configured and ready-to-go.

Pre-configured for https://github.com/Ouranosinc/PAVICS-e2e-workflow-tests, see
[`jobs.yaml`](jcasc/jobs.yaml).

Still generic enough that any additional jobs/configurations can be added, see
`JCASC_DIR` and `JCASC_EXTRA_DIRS` in [`env.local.example`](env.local.example).

Note the `PAVICS-e2e-workflow-tests` job above brings its own Docker runtime
environment so this Jenkins config do not have to change for any new jobs
added.


## Usage

Ensure you have [docker](https://www.docker.com/) and
[docker-compose](https://docs.docker.com/compose/) installed on your Linux
host.

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
```shell
./jenkins-compose.sh down -v  # only delete anonymous data volume
git pull
# update env.local with new variables from env.local.example if needed
scripts/backup-jenkins-master.sh  # backup to /tmp
./jenkins-compose.sh up -d
# multibranch pipeline jobs might need a manual "Scan Multibranch Pipeline Now"
# to keep Stage View intact
```

See
[canarie-presentation/presentation.slides.html](canarie-presentation/presentation.slides.html)
for a demo run of this repo.  Github do not play the presentation, you'll have
to download it and open it locally with your internet browser (tested with
Firefox and Chromium/Chrome only).


## Data Persistance

This deployment uses named docker volume for data persistance.  Two named
volume will be created and will survive `./jenkins-compose.sh down -v`:

* jenkins_master_home_$JENKINS_MASTER_PORT
* jenkins_slave_home_$JENKINS_MASTER_PORT

The jenkins_master_home one is important as it contains build history, logs and
user passwords.

The jenkins_slave_home only contains the workspaces where the build occurred.

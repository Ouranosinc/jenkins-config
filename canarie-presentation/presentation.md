# Demo of Jenkins Configuration as Code plugin


## Jenkins without Configuration as Code plugin

![Jenkins without Configuration as Code plugin animated
gif](jenkins-manual.gif "Jenkins without Configuration as Code plugin")

Problems:

* No automated configuration sync between Production and Staging instances

* Very time consuming to manually reconfigure a fresh instance to replicate
  exactly the same configurations

* No tracking who changed which config, when, why


## Jenkins using Configuration as Code plugin

![Jenkins using Configuration as Code plugin animated
gif](jenkins-with-jcasc.gif "Jenkins using Configuration as Code plugin")

* Fixes all the problems above

* Follows the DevOPS way of "Infrastructure as Code"

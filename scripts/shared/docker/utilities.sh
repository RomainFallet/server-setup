#!/bin/bash

function GetDockerContainerId () {
  dockerContainerName="${1}"
  sudo docker ps --all --quiet --filter name="${dockerContainerName}"
}

function StopDockerContainerWithDockerCli () {
  containerName="${1}"
  sudo docker stop "${containerName}" > /dev/null
}

function RemoveDockerContainerWithDockerCli () {
  containerName="${1}"
  sudo docker rm "${containerName}" > /dev/null
}

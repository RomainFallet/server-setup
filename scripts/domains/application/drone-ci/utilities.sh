#!/bin/bash

# shellcheck source-path=../../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/docker/index.sh"

function CreateDroneCiDockerContainer () {
  dockerContainerName="${1}"
  droneDataPath="${2}"
  droneDomainName="${3}"
  droneInternalPort="${4}"
  droneSharedSecretKey="${5}"
  giteaDomainName="${6}"
  giteaClientId="${7}"
  giteaClientSecret="${8}"
  RemoveDockerContainerIfExisting "${dockerContainerName}"
  sudo docker create \
    --volume="${droneDataPath}":/data \
    --env=DRONE_GITEA_SERVER="${giteaDomainName}" \
    --env=DRONE_GITEA_CLIENT_ID="${giteaClientId}" \
    --env=DRONE_GITEA_CLIENT_SECRET="${giteaClientSecret}" \
    --env=DRONE_RPC_SECRET="${droneSharedSecretKey}" \
    --env=DRONE_SERVER_HOST="${droneDomainName}" \
    --env=DRONE_SERVER_PROTO=https \
    --publish="${droneInternalPort}":80 \
    --restart=always \
    --name="${dockerContainerName}" \
    drone/drone:2
}

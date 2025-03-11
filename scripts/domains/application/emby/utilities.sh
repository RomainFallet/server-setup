#!/bin/bash

# shellcheck source-path=../../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/files/index.sh"
# shellcheck source-path=../../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/variables/index.sh"

function SelectAppropriateEmbyArchitecture () {
  processorArchitecture=$(uname -m)
  if [[ "${processorArchitecture}" == 'aarch64' ]]; then
    echo "arm64"
  elif [[ "${processorArchitecture}" == 'x86_64' ]]; then
    echo "amd64"
  else
    echo "amd64"
  fi
}

function GetLatestEmbyVersion () {
  filePath=/tmp/emby-latest-release.html
  DownloadFile 'https://github.com/MediaBrowser/Emby.Releases/releases/latest' "${filePath}"
  releaseContent=$(cat "${filePath}")
  versionLine=$(echo "${releaseContent}" | grep "<title>Release ")
  rawVersion=$(echo "${versionLine}" | sed -E 's/<title>Release ([0-9]+)\.([0-9]+)\.([0-9]+)\.([0-9]+).+/\1.\2.\3.\4/g')
  version=$(Trim "${rawVersion}")
  RemoveFile "${filePath}"
  echo "${version}"
}

function DownloadEmby () {
  embyDownloadPath="${1}"
  embyLatestVersion="${2}"
  embyArchitecture=$(SelectAppropriateEmbyArchitecture)
  echo "URL: https://github.com/MediaBrowser/Emby.Releases/releases/download/${embyLatestVersion}/emby-server-deb_${embyLatestVersion}_${embyArchitecture}.deb"
  DownloadFile "https://github.com/MediaBrowser/Emby.Releases/releases/download/${embyLatestVersion}/emby-server-deb_${embyLatestVersion}_${embyArchitecture}.deb" "${embyDownloadPath}"
}

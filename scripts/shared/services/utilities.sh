#!/bin/bash

function ReloadSystemdServiceFiles () {
  sudo systemctl daemon-reload
}

function EnableSystemdService () {
  serviceName="${1}"
  sudo systemctl enable "${serviceName}.service"
}

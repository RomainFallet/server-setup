#!/bin/bash

function ReloadSystemdServiceFiles () {
  sudo systemctl daemon-reload
}

function EnableSystemdService () {
  serviceName="${1}"
  sudo systemctl enable "${serviceName}.service"
}

function RestartSystemdService () {
  serviceName="${1}"
  sudo systemctl restart "${serviceName}.service"
}


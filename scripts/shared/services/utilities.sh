#!/bin/bash

function ReloadSystemdServiceFiles () {
  sudo systemctl daemon-reload
}

function EnableSystemdService () {
  serviceName="${1}"
  sudo systemctl enable "${serviceName}.service"
}

function DisableSystemdService () {
  serviceName="${1}"
  sudo systemctl disable "${serviceName}.service"
}

function EnableSystemdPath () {
  serviceName="${1}"
  sudo systemctl enable "${serviceName}.path"
}

function RestartSystemdService () {
  serviceName="${1}"
  sudo systemctl restart "${serviceName}.service"
}

function RestartSystemdPath () {
  serviceName="${1}"
  sudo systemctl restart "${serviceName}.path"
}

function StartSystemdService () {
  serviceName="${1}"
  sudo systemctl restart "${serviceName}.service"
}

function StopSystemdService () {
  serviceName="${1}"
  sudo systemctl stop "${serviceName}.service"
}

function FollowSystemdServiceLogs () {
  serviceName="${1}"
  sudo journalctl --follow --unit "${serviceName}.service"
}

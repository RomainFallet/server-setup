#!/bin/bash

function MountDevice () {
  devicePath="${1}"
  mountPath="${2}"
  sudo mount "${devicePath}" "${mountPath}"
}

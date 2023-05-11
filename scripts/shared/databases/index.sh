#!/bin/bash

function CreatePostgreSqlDatabaseIfNotExisting () {
  databaseName="${1}"
  existingData=$(sudo su --command "psql --command \"SELECT datname FROM pg_database WHERE datname = '${databaseName}';\"" - postgres)
  if ! (echo "${existingData}" | grep "${databaseName}" > /dev/null); then
    sudo su --command "psql --command \"CREATE DATABASE ${databaseName} ENCODING UTF8;\"" - postgres
  fi
}

function GrantAllPrivilegesOnPostgreSqlDatabase () {
  databaseName="${1}"
  userName="${2}"
  sudo su --command "psql --command \"GRANT ALL PRIVILEGES ON DATABASE ${databaseName} to ${userName};\"" - postgres
}

function CreatePostgreSqlUserIfNotExisting () {
  userName="${1}"
  password="${2}"
  existingData=$(sudo su --command "psql --command \"SELECT usename FROM pg_user WHERE usename = '${userName}';\"" - postgres)
  if ! (echo "${existingData}" | grep "${userName}" > /dev/null); then
    sudo su --command "psql --command \"CREATE ROLE ${userName} WITH LOGIN PASSWORD '${password}';\"" - postgres
  fi
  sudo su --command "psql --command \"ALTER USER ${userName} PASSWORD '${password}';\"" - postgres
}

#!/bin/bash

set -eu -o pipefail

container_name='timescale-exploration'
timescaledb_version='2.16.1-pg15' # default version
host='localhost'
default_database='postgres'
port='32800'


print_usage() {
  echo "Usage: ./init_timescaledb_docker.sh [options]"
  echo "Options:"
  echo "   -d: Sets the TimescaleDB version of the container. Default is the latest verion."
  echo "   -i: Shows the connection information for the container."
}


get_timescaledb_version() {
    if [ -z "$1" ]; then
        timescaledb_version='latest-pg15'
    else
        if [[ $1 =~ "2.16" ]]; then
            timescaledb_version='2.16.1-pg15'
        elif [[ $1 =~ "2.15" ]]; then
             timescaledb_version='2.15.1-pg15'
        elif [[ $1 =~ "2.14" ]]; then
            timescaledb_version='2.14.1-pg15'
        elif [[ $1 =~ "2.13" ]]; then
             timescaledb_version='2.13.1-pg15'
        else
            echo "Invalid TimescaleDB version. Please use 2.16, 2.15, 2.14, or 2.13."
            exit 1
        fi
    fi
}

get_connection_info() {

    if [[ "$(docker ps -a | grep -c $container_name)" -le 0 ]] || [[ -z "`docker inspect -f {{.State.Running}} $container_name`"=="healthy" ]] ; then
        echo "Cannot get connection info. Container '$container_name' is not running."
        exit 1
    fi

    if [[ -z "`docker inspect -f {{.State.Running}} $container_name`"=="healthy" ]]; then
        echo "Container is not running."
        exit 1
    fi

    echo "Connection info:"
    echo "Host: $host"
    echo "Port: $port"
    echo "Database: $default_database" #default database
    echo "Username: postgres" #default user
    echo "Password: mysecretpassword"
    echo "Connection string: jdbc:postgresql://localhost:$port/$default_database"
}


# Check for options being set via command-line arguments.
while getopts 'd:i?' flag; do
  case "${flag}" in
  d) get_timescaledb_version ${OPTARG} ;;
  i) get_connection_info
     exit 0 ;;
  ?) print_usage
     exit 0 ;;
  *)
    echo "Unexpected arguments."
    print_usage
    exit 1
    ;;
  esac
done


create_container() {

    echo "Removing existing container..."

    docker rm --force $container_name

    echo "Starting TimescaleDB $timescaledb_version Docker container..."

    docker run -d --rm --name $container_name -e POSTGRES_PASSWORD=mysecretpassword -p $port:5432 timescale/timescaledb:$timescaledb_version
    
    echo "Waiting for container to be healthy..."

    until [ "`docker inspect -f {{.State.Running}} $container_name`"=="healthy" ]; do
        sleep 0.1;
    done;

    echo "Container is healthy."
}

setup_sql() {

     echo "Running setup SQL..."

    # runs the setup sql script 
    cat ./setup.sql | docker exec -i $container_name psql -U postgres postgres >/dev/null
}

main() {

    create_container

    # wait for the container to be ready
    sleep 3

    setup_sql

}

main
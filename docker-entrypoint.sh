#!/bin/bash

function defaults {
    : ${DEVPISERVER_SERVERDIR="/data/server"}
    : ${DEVPI_CLIENTDIR="/data/client"}

    echo "DEVPISERVER_SERVERDIR is ${DEVPISERVER_SERVERDIR}"
    echo "DEVPI_CLIENTDIR is ${DEVPI_CLIENTDIR}"

    export DEVPI_SERVERDIR DEVPI_CLIENTDIR
}

function initialise_devpi {
    echo "[RUN]: Initialise devpi-server"
    devpi-server --restrict-modify root --start --host 127.0.0.1 --port 3141 --outside-url https://pypi.doubanio.com/simple/
	devpi-init --root-passwd "${DEVPI_PASSWORD}"
    devpi-server --status
    devpi use http://localhost:3141
    devpi login root --password=''
    devpi user -m root password="${DEVPI_PASSWORD}"
    devpi index -y -c public pypi_whitelist='*'
	# https://github.com/devpi/devpi/issues/433
	devpi index root/pypi mirror_url="https://pypi.doubanio.com/simple/"
    devpi-server --stop
    devpi-server --status
}

defaults

if [ "$1" = 'devpi' ]; then
    if [ ! -f  $DEVPISERVER_SERVERDIR/.serverversion ]; then
        initialise_devpi
    fi

    echo "[RUN]: Launching devpi-server"
    exec devpi-server --restrict-modify root --host 0.0.0.0 --port 3141
fi

echo "[RUN]: Builtin command not provided [devpi]"
echo "[RUN]: $@"

exec "$@"

#!/dumb-init /bin/sh
set -e

if [ -z "$DATA" ];   then export DATA=/data     ; fi
if [ -z "$LISTEN" ]; then export LISTEN=":8000" ; fi
if [ -z "$UID" ];    then export UID=1000       ; fi
if [ -z "$GID" ];    then export GID=1000       ; fi


DEFAULT_ARGS="--no-auth --prometheus --path ${DATA} --listen ${LISTEN}"
if [ -z "$@" ]; then export ARGS="${DEFAULT_ARGS}" ; fi

echo "
================================================
DATA=${DATA}
UID=${UID}
GID=${GID}
LISTEN=${LISTEN}
===
ARGS=${ARGS}
================================================"

set -x
mkdir -p ${DATA}
chown -R ${UID}:${GID} ${DATA}

# finally.. launch the rest-server
/gosu ${UID}:${GID} /rest-server ${ARGS}

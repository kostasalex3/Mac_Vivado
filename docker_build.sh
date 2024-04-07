#!/bin/bash

open /Applications/Docker.app
# Default version 2017.4
XILVER=${1:-2017.4}





# Default Vivado build number
XXXX_X=${2:-1216_1}

# Check HTTP server is running
PYTHONV=$(python3 --version 2>&1 | cut -f2 -d' ')
case $PYTHONV in
    3*) PYTHONHTTP="http.server" ;;
    *) PYTHONHTTP="SimpleHTTPServer" ;;
esac
# shellcheck disable=SC2009
if ! ps -fC | grep python | grep "$PYTHONHTTP" > /dev/null ; then
    python3 -m "$PYTHONHTTP" &
    HTTPID=$!
    echo "HTTP Server started as PID $HTTPID"
    trap 'kill $HTTPID' EXIT QUIT SEGV INT HUP TERM ERR
fi

echo "Creating Docker image mac_vivado_2017_4:$XILVER..."
time docker build . -t mac_vivado_2017_4:"$XILVER" --build-arg XILVER="${XILVER}" --build-arg XXXX_X="${XXXX_X}"
[ -n "$HTTPID" ] && kill $HTTPID && echo "Killed HTTP Server"
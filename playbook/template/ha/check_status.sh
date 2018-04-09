#!/bin/bash
curl -I -k https://127.0.0.1:{{ apiserver_port }} &>/dev/null
exit $?

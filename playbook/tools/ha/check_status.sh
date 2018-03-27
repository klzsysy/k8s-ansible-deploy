#!/bin/bash
curl -I -k https://127.0.0.1:8443 &>/dev/null
exit $?
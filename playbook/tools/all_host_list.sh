#!/usr/bin/env bash
#
source xgrep.sh

etc_hosts=
for host in $(ansible -i $1 all --list-hosts | tail -n +2)
do
    _hostname="\"${host}\","
    _hostip="\"$(ping ${host} -c 1 | xgrep -o -P '\d+\.+\d+\.\d+\.\d+' | head -n 1)\","
    etc_hosts="${_hostname}\n${_hostip}\n${etc_hosts}"
done
etc_hosts=$(echo -e "$etc_hosts" | sort  | uniq)
echo  "${etc_hosts}"

#!/usr/bin/env bash
xgrep(){
    # 为了兼容macos
    which ggrep &>/dev/null
    if [ $? -eq 0 ];then
        ggrep "$@"
    else
        grep "$@"
    fi
}


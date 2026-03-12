#!/bin/bash
function getActiveScriptDir() {
    src="$0"
    while [ -h "$src" ]; do
        local dir="$( cd -P "$( dirname "$src" )" && pwd )"
        src="$( readlink "$src" )"
        [[ $src != /* ]] && $src="$dir/$src"
    done
    cd -P "$( dirname "$src" )"
    pwd
}
function getProjectRoot() {
    src="${BASH_SOURCE[0]}"
    while [ -h "$src" ]; do
        local dir="$( cd -P "$( dirname "$src" )" && pwd )"
        src="$( readlink "$src" )"
        [[ $src != /* ]] && $src="$dir/$src"
    done
    cd -P "$( dirname $( dirname "$src" ) )"
    pwd
}
function getConfigDir() {
    local rootDir="$( getProjectRoot )"
    echo "$rootDir/config"
}
function srcConfigFile() {
    local file="$1"
    source "$( getConfigDir )/$file"
}
function srcLibFile() {
    local file="$1"
    source "$( getProjectRoot )/config/$file"
}

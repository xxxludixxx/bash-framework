#!/bin/bash

# test 3

function init() {
    # Stop on Error
    set -e
    # Stop on undefined variable
    set -u
    # Debug trace
    #set -x

    local self=${BASH_SOURCE[0]};
    local absSelf=$(readlink -f "${self}")
    local absSelfDir=$( cd "$( dirname "${absSelf}" )" && pwd )
    
    BASE_DIR="${absSelfDir}"

    source "${BASE_DIR}/core/bootstrap.sh"
    source "${BASE_DIR}/app/bootstrap.sh"

    coreBootstrap;
    appBootstrap;
}

function main() {
    init;
    
    coreDefaultMain "$@";
}
main "$@";

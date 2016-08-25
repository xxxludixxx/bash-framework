
# Entry point of the command
function runAction() {
    local action="${1:-start}";
    local commitMessage="${2:-}";

    if [ "${action}" == "start" ]; then
        coreDevEnableSymlinks
    elif [ "${action}" == "stop" ]; then
        coreDevDisableSymlinks
    elif [ "${action}" == "status" ]; then
        coreDevGitStatus
    elif [ "${action}" == "commit" ]; then
        if [ -z "${commitMessage}" ]; then
            error "You must provide a message for commit"
        fi

        coreDevCommit "${commitMessage}" "${arg_p}" 
    else
        error "Unknown action '${action}'. Must be one of: 'start', 'stop', 'commit', 'status'";
    fi
    
}


function systemInstallCron() {
    local marker="$(systemAppCode)-${1}"
    local command="${2}"

    debug "Installing '${marker}' to crontab..."

    local crontabLine="${command}  # ${marker}"

    local tmpCronFile=$(mktemp)

    crontab -l | grep -v "${marker}" | echo "$(cat -; echo "${crontabLine}")" | silentPipe "${tmpCronFile}"

    runSilent crontab ${tmpCronFile}
    runSilent rm -rf ${tmpCronFile}

}

function systemUninstallCron() {
    local marker="$(systemAppCode)-${1}"

    debug "Uninstalling crontab marked by '${marker}'..."

    local tmpCronFile=$(mktemp)

    crontab -l | grep -v "${marker}" | silentPipe "${tmpCronFile}"

    runSilent crontab ${tmpCronFile}
    runSilent rm -rf ${tmpCronFile}
}


function systemRegisterCLICommand() {
    local cmd="${1:-$(systemAppCode)}"
    local dstRelFile="${2:-run.sh}"

    runSilent filesMakeSymlink "$(systemInstallDir)/${dstRelFile}" "$(systemCommandsDir)/${cmd}"
}

function systemUnregisterCLICommand() {
    local cmd="${1:-$(systemAppCode)}"

    runSilent filesRemove "$(systemCommandsDir)/${cmd}"
}

function systemInstallTo() {
    local installDir="${1-$(systemInstallDir)}"
    
    if [ -e "${installDir}" ]; then
        error "${installDir} already exists. Please uninstall it first."
    fi

    runSilent filesMkdir "${installDir}";
    runSilent filesCopy "${BASE_DIR}/." "${installDir}";
}

function systemUninstallFrom() {
    local installDir="${1-$(systemInstallDir)}"

    runSilent filesRemove "${installDir}";
}

function systemInstallDir() {
    echo "/home/$(whoami)/bin/$(systemAppCode)-project"
}

function systemCommandsDir() {
    echo "/home/$(whoami)/bin"
}

function systemAppCode() {
    if [ -z "${appCode:-}" ]; then
        error "You must export 'appCode' variable in app/config/common/config.sh"
    fi
    echo "${appCode/_/-}";
}

function systemShowTime() {
    time "$@"
}

function systemShowLongTime() {
    "$@"
    local ret=$?

    if (( $SECONDS > ${coreShowMeasuredTimeWhenActionTakesLongerThanSec} )); then    
       >&2 echo ""
       >&2 echo " ================== "
       >&2 echo "  Time: $SECONDS sec."
       >&2 echo " ================== "
    fi

    return ${ret};
}



function systemHasActiveStream() {
    if [[ -t 1 ]]; then
        return 1;
    fi
    return 0;
}

function systemEnsureHasActiveStream() {
    if ! systemHasActiveStream; then
        error "Didn't detected a stream descriptor";  
    fi
}
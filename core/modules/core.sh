
CORE_CURRENT_ACTION=''
CORE_USE_FRONT_ROUTER=0

function coreLoad() {
    local type="${1}"
    local file="${2}"
    local comandName="${3:-}"
    
    local dimension="${4:-}"
    local currentDimension="${5:-}"
    
    coreIncludeSource $( coreBuildPath "core" "${type}" "${comandName}" "${dimension}" "${currentDimension}" "${file}" );
    coreIncludeSource $( coreBuildPath "app" "${type}" "${comandName}" "${dimension}" "${currentDimension}" "${file}" );
}

function coreProjectCode() {
    if [ -z "${appCode}" ]; then
        basename "${BASE_DIR}"
    else
        echo "${appCode}";
    fi
}

function coreRouterName() {
    echo 'run.sh';
}

function coreIncludeSource() {
    local path="${1}"

    if [[ -r "${path}" ]]; then
        source "${path}"
    fi
}

function coreBuildPath() {
    #local pool="${1}"
    #local type="${2}"
    #local command="${3}"
    #local dimension="${4}"
    #local currentDimension="${5}"
    #local file="${6}"

    local path="${BASE_DIR}"
    
    for arg in "${@}"; do
        if [[ ! -z "${arg}" ]]; then
            path="${path}/${arg}"
        fi
    done

    echo "${path}"
}

function coreIsCommandValid() {
    local command="${1:-}"

    if [[ -z "${command}" ]]; then
        echo "Command wasn't provided"
        return 1;
    elif [[ "${command:0:1}" == "-" ]] || ! inArray "${command}" "$( coreCommandsList )"; then
        echo "Invalid command: '${command}'"
        return 1;
    fi

    return 0;
}

function coreEnsureCommandValid() {
    local command="${1:-}"

    local error=$(coreIsCommandValid "${command}")
    if [ ! -z "${error}" ] ; then
        printUsage "${error}"
    fi
}

function parametersUsage() {
    corePrintCommonUsage
    actionUsageBelow
}

function coreCheckUpgrade() {
    coreLoadAction "core-upgrade"
    checkUpdate
}

function coreCommandsList() {
    local mode=${1:-'flat'}
    local loadedUsage=""
    local i=0

    for pool in "core" "app"
    do
        for commandDir in $(ls "${BASE_DIR}/${pool}/commands/"); 
        do
            if ! [[ "${loadedUsage[@]}" =~ " ${commandDir%%/} " ]]; then
                loadedUsage[((++i))]="${commandDir%%/}"
            fi
        done
    done

    if [ "${mode}" == "list" ]; then
        echo "${loadedUsage[@]}"  | sed -e 's/^[ \t]*//' | tr " " "\n" | sed 's/^/  /'
    else
        echo "${loadedUsage[@]}"
    fi
}

function usageScheme() {
    if [[ -z "${CORE_CURRENT_ACTION}" ]]; then
        echo "${0} command [parameters]";
        echo '';
    else
        if [ "${CORE_USE_FRONT_ROUTER}" = "0" ]; then
            echo "${0} $(actionUsagePositionParameters) [parameters]";
        else
            echo "${0} ${CORE_CURRENT_ACTION} $(actionUsagePositionParameters) [parameters]";
        fi

        echo '';
        echo "$(actionUsageDescription)"
        echo '';
    fi
}

function usage() {
    if [[ -z "${CORE_CURRENT_ACTION}" ]]; then
        corePrintCommonUsage;
        corePrintCoreUsage;
    else
        corePrintCommandUsage;
    fi
}

function corePrintCommonUsage() {
    configLoad 'commonUsage.sh'
}

function corePrintCoreUsage() {
    local msg=$(
        echo "Where 'command' may be one of:"
        echo "$( coreCommandsList list )"
    );
    echo "${msg}"
}

function corePrintCommandUsage() {
    actionUsageAbove
    corePrintCommonUsage;
    actionUsageBelow
}

function coreLoadUsage() {
    local command="${1}"
    
    coreResetUsage
    coreLoad "commands" "usage.sh" "${command}"
}

function coreResetUsage() {
    eval "function actionUsageDescription() { local foo; }";
    eval "function actionUsageAbove() { local foo; }";
    eval "function actionUsageBelow() { local foo; }";
    eval "function actionUsagePositionParameters() { local foo; }";
}

function coreLoadAction() {
    local command="${1}"

    coreEnsureCommandValid "${command}"

    coreLoad "commands" "action.sh" "${command}" 
    coreLoadUsage "${command}"
}

function coreRunAction() {
    local command="${1}"

    CORE_CURRENT_ACTION='';

    if argumentsHaveAHelpMark "${@}"; then
        local error=$(coreIsCommandValid "${command}")
        if [ -z "${error}" ] ; then
            CORE_CURRENT_ACTION="${command}";
            coreLoadUsage "${command}"
        fi

        printUsage 
    fi

    coreEnsureCommandValid "${command}"
    CORE_CURRENT_ACTION="${command}";

    coreCheckUpgrade
    coreLoadAction "${command}"

    shift 1
    parseArguments "$@"

    systemShowLongTime runAction "${@}"
}

function coreDefaultMain() {
    local command="${1:-}"

    CORE_USE_FRONT_ROUTER=1

    if [ -z "${command}" ]; then
        coreRunAction '' "$@"
    else
        coreRunAction "$@"
    fi

    CORE_USE_FRONT_ROUTER=0
}

function coreCleanupBeforeExit() {
  # We can clean resources here
  appCleanupBeforeExit;
  return 0;
}
trap coreCleanupBeforeExit EXIT



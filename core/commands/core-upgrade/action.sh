
BACKUP_DIR=""
UPGRADE_DIR=""

#Enter point of the command
function runAction() {

    doBackup
    doUpgrade 
    persistCurrentVersion
    cleanupAfterUpgrade 

    info "Successfuly Upgrated ! :)"
}

function doBackup() {
    BACKUP_DIR=$( createTmpDir )

    debug "Making a backup of current core... (${BACKUP_DIR})"
    
    copy "${BASE_DIR}/core/" "${BACKUP_DIR}/core/"
    copy "${BASE_DIR}/run.sh" "${BACKUP_DIR}/run.sh"
}

function doUpgrade() {

    if [ "${arg_c}" == 1 ] && ! gitIsCleanState "${BASE_DIR}" ; then
        error "It seems that You have uncommited changes. Clear your state first."
    fi

    UPGRADE_DIR=$( createTmpDir )

    debug "Cloning recent core to the temp folder..."
    
    remove "$(needUpdateFile)"
    gitClone "${BASH_BASE_REPO}" "${UPGRADE_DIR}" 

    debug "Replacing current app core by recent version..."

    remove "${BASE_DIR}/core/" "${BASE_DIR}/run.sh" 
    copy "${UPGRADE_DIR}/core/" "${BASE_DIR}/core/"
    copy "${UPGRADE_DIR}/run.sh" "${BASE_DIR}/run.sh"

    if [[ "${arg_c}" == 1 ]] ; then
        gitCommit "${BASE_DIR}" "Core-upgrade auto commit"
    fi
}

function cleanupAfterUpgrade() {
    debug "Removing temporary core folder..."
    remove "${BACKUP_DIR}" "${UPGRADE_DIR}" "$(needUpdateFile)"
}

function persistCurrentVersion() {
    echo "UPGRADE_HASH=\"$(remoteGitHash)\"" > "$(versionFilePath)"
}

function checkUpdate() {
    if ! isAllowedHost || ! isAllowedLocation; then
        return 0;
    fi;

    # Run checking with 10% probability
    runMaybe 10 doCheckUpdate
}

function doCheckUpdate() {
    debug "Checking for new core version..."
    
    if [[ ! -f "$(checkUpdatesFile)" || -f "$(needUpdateFile)" ]]; then
        touch "$(checkUpdatesFile)"

        if [[ -f "$(needUpdateFile)" || $( localGitHash ) != $( remoteGitHash ) ]]; then 
            touch "$(needUpdateFile)"

            local msg=$(
                echo -e "\x1b[31m"
                echo ""
                echo "########################################################"
                echo "# Run '$(coreRouterName) core-upgrade' to upgrade framework core! #"
                echo "########################################################"
                echo -e "\e[0m"
            );
            warning "${msg}"
        fi
    fi;
}

function isAllowedHost() {
    local currnetHost="$(hostname -d)"

    if [[ "${currnetHost}" == "dallas.creatuity.internal" ]]; then
        return 1
    fi
    
    return 0
}

function isAllowedLocation() {
    local absCurrentPath="$(filesAbsPath $(pwd))";

    if [[ "${absCurrentPath}" =~ ^/var/www/html/(.*)$ ]]; then
        return 0;
    else
        return 1;
    fi
}

function localGitHash() {
    if [[ $( currentRemoteGitUrl ) == ${BASH_BASE_REPO} ]]; then
        echo "$(gitLocalHash ${BASE_DIR})"
        return 0;
    fi;

    if [[ ! -f "$(versionFilePath)" ]]; then
        persistCurrentVersion
    fi

    source "$(versionFilePath)";
    echo "${UPGRADE_HASH}";
}

function remoteGitHash() {
    gitRemoteHash "${BASH_BASE_REPO}"
}

function versionFilePath() {
    echo "${BASE_DIR}/core/commands/core-upgrade/version.sh"
}

function checkUpdatesFile() {
    echo "/tmp/$(whoami)_bash_bash_$(date +%m%d%y)"
}

function needUpdateFile() {
    echo "/tmp/$(whoami)_bash_bash_need_update"
}

function currentRemoteGitUrl() {
    gitCurrentRemoteUrl "${BASE_DIR}"
}


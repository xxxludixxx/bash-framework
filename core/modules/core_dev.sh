

function coreDevEnableSymlinks() {
    coreDevEnsureOriginalRepoIsInPlace

    info "Enabling symlinks..."
    coreDevModmanSymlinks
}

function coreDevDisableSymlinks() {
    # coreDevEnsureOriginalRepoIsInPlace

    info "Disabling symlinks..."
    coreDevModmanCopy
}

function coreDevGitStatus() {
    coreDevEnsureSymlinksEnabled

    runInTrap coreDevModmanSymlinks coreDoDevGitStatus
}

function coreDoDevGitStatus() {
    coreDevModmanCopy
    gitState "${BASE_DIR}"
}

function coreDevCommit() {
    local message="${1}";
    local pushFlag="${2:-0}";

    coreDevEnsureSymlinksEnabled

    runInTrap coreDevModmanSymlinks coreDoDevCommit
}

function coreDevEnsureSymlinksEnabled() {
    if ! coreDevIsCoreSymlinking; then
        error "You can commit only when symlinks are enabled. Use '$(coreRouterName) core-dev start'."
    fi
}

function coreDoDevCommit() {
    coreDevDisableSymlinks

    if  gitIsCleanState "${BASE_DIR}"; then
        error "Nothing to commit"
    fi

    gitAddAll "${BASE_DIR}"
    gitState "${BASE_DIR}"
    ensureCanContinue "Are You sure You want to commit all above changes?"

    info "Committing changes..."
    runSilent gitCommit "${BASE_DIR}" "${message}"
    runSilent gitCommit "$(coreDevAbsModmanPath)" "Core update during work on $(coreProjectCode) (${message})"

    if [ "${pushFlag}" == "1" ]; then
        info "Pushing changes to app remote repo"
        runSilent gitPush "${BASE_DIR}" "pull-first"

        info "Pushing changes to core remote repo"
        runSilent gitPush "$(coreDevAbsModmanPath)" "pull-first"
    fi
}


function coreDevIsCoreSymlinking() {
    if [ -L "${BASE_DIR}/core" ]; then
        return 0;
    fi
    return 1;
}

function coreDevModmanSymlinks() {
    if [ ! -d "$(coreDevAbsModmanPath)" ]; then
        error "No modman repo"
    fi

    cd "${BASE_DIR}"
    runSilent modman repair --force;
}

function coreDevModmanCopy() {
    if [ ! -d "$(coreDevAbsModmanPath)" ]; then
        error "No modman repo"
    fi

    cd "${BASE_DIR}"
    runSilent modman repair --force --copy;
}

function coreDevEnsureOriginalRepoIsInPlace() {
    info "Downloading the most recent core version..."

    runSilent filesMkdir "${BASE_DIR}/.modman/"

    if [ ! -d "$(coreDevAbsModmanPath)" ]; then
        runSilent gitClone "${BASH_BASE_REPO}" "$(coreDevAbsModmanPath)"
    else   
        runSilent gitPull "$(coreDevAbsModmanPath)"
    fi

    runSilent filesCopy "$(coreDevAbsModmanPath)/core/commands/core-dev/modman" "$(coreDevAbsModmanPath)/modman" 
}

function coreDevAbsModmanPath() {
    echo "${BASE_DIR}/$(coreDevModmanPath)";
}



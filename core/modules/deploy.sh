
function deployInstall() {
    deployLoadConfig;
    coreInstall;
    appInstall;
}

function deployUninstall() {
    ensureCanContinue "Are You sure You want to uninstall?"

    deployLoadConfig;
    appUninstall;
    coreUninstall;
}


function deployRunUpgradeScripts() {
    deployLoadConfig;

    deployRunUpgradeScriptsForScope "core"
    deployRunUpgradeScriptsForScope "app"
}

function deployRunUpgradeScriptsForScope() {
    local scope="${1}"
    local currVersion="$(deployReadVersion $scope)"
    local version="$((${currVersion} + 1))"

    while [ "$(type -t ${scope}Upgrade_${version})" == "function" ]; do
        info "Running ${scope}Upgrade_${version}()..."
        eval "${scope}Upgrade_${version}";
        
        deploySaveVersion "$scope" "${version}"
        version=$((${version} + 1));
    done
}

function deployReadVersion() {
    local scope="${1}"
    local currentVersion="0";

    if [ -e "${BASE_DIR}/.deploy/${scope}.version" ]; then
        local content=$(cat "${BASE_DIR}/.deploy/${scope}.version");

        if [[ "$content" =~ ^-?[0-9]+$ ]]; then
            currentVersion="$content"
        fi
    fi
    echo "${currentVersion}"
}

function deploySaveVersion() {
    local scope="${1}"
    local version="${2}";

    if [[ ! "$version" =~ ^-?[0-9]+$ ]]; then
        error "version must be a number"
    fi

    runSilent filesRemove "${BASE_DIR}/.deploy/${scope}.version" || true
    runSilent filesMkdir "${BASE_DIR}/.deploy/"
    echo -n "${version}" > "${BASE_DIR}/.deploy/${scope}.version"
}

function deployLoadConfig() {
    configLoad "coreDeploy.sh"
    configLoad "deploy.sh"
}


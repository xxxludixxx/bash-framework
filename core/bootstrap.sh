# --- Core Bootstrap  ---

function coreDevModmanPath() {
    # Unfortunately, we need this to be here because we need that to boostrap properly
    echo ".modman/bashBaseOriginal"
}

function coreBootstrap() {
    # path correction for 'core-symlink' purpose
    if [[ "${BASE_DIR}" == *"$(coreDevModmanPath)"* ]]; then
        BASE_DIR="${BASE_DIR/$(coreDevModmanPath)/}"
    fi;

    coreLoadModules "${BASE_DIR}/core/modules"
    coreLoadModules "${BASE_DIR}/app/modules"
    
    configLoad "coreConfig.sh"
    configLoad "config.sh"

    deployRunUpgradeScripts
}

function coreLoadModules() {
    local dir=${1}

    local sources=$(
        find "${dir}" -type f -iname "*.sh" -print0 | while IFS= read -r -d $'\0' module; do
            echo "source \"${module}\""
        done
    );
    
    eval "$sources"
}

# --- Default App Implementations ---

function appBootstrap() {
    # to be overriden in app/
    local dummy=1;
}

function appDimensionsConfig() {
    # to be overriden in app/
    local dummy=1;
}

function appCleanupBeforeExit() {
    # to be overriden in app/
    local dummy=1;
}

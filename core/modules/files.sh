
function filesRemove() {
    for arg in "${@}"; do
        $( yes | rm -rf "${arg}" )
    done    
}

function filesCopy() {
    local from="${1}"
    local to="${2}"

    $( yes | cp -rf "${from}" "${to}" )
}

function filesMove() {
    local from="${1}"
    local to="${2}"

    $( yes | mv -rf "${from}" "${to}" )
}

function filesMakeSymlink() {
    local symlinkDestination="${1}"
    local symlinkItself="${2}"
    local force="${3:-noforce}"

    if [ -e "${symlinkItself}" ]; then
        if [ "${force}" == "force" ]; then
            filesRemove "${symlinkItself}"
        else
            error "Cannot create a symbolic link at ${symlinkItself}, because something exists under that destination"
        fi        
    fi

    ln -s "${symlinkDestination%/}" "${symlinkItself}"
}

function filesRemoveSymlink() {
    local path="${2}"
    
    if [!  -L "${path}" ]; then
        error "${path} is not a symbolic link!";
    fi
    
    local pathWithoutTrailingSlash="${path%/}";
    filesRemove "${pathWithoutTrailingSlash}"
}

function filesMkdir() {
    if [ -z "${2:-}" ]; then
        mkdir -p "${@}"
    else
        mkdir "${@}"
    fi
}

function filesMkdirEmpty() {
    filesRemove "${1}"
    filesMkdir "${1}"
}

function filesAbsPath() {
    local path="${1}"
    local path=$(readlink -e "${path}")
    while [ "${path:(-1)}" == "/" ]; 
    do
        entry="${path::-1}"
    done
    echo "${path}"
}
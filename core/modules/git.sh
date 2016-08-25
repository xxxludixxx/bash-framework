#!/bin/bash

export gitUseGitCloner=0


function gitClone() {
    if [ -z ${1+x} ] || [ -z ${2+x} ]; then
        error "Missing parameter"
    fi;

    if [ "$( runSilent ls -A ${2} )" ]; then
        error "'${2}' must be empty."
    fi
    
    if [ "${gitUseGitCloner}" == "1" ]; then
        run git-cloner "${1}" "${2}";
    else
        run git clone "${1}" "${2}";
    fi
}

function gitCheckout() {
    ensureFirstParamIsAPathToGit "$@"
    if [ -z ${2+x} ]; then
        error "Missing parameter"
    fi;

    cd "${1}"
    run git checkout "${2}"
}

function gitCurrentBranch() {
    ensureFirstParamIsAPathToGit "$@"

    cd "${1}"

    branch=$(run git rev-parse --abbrev-ref HEAD)

    if [ "$branch" == "HEAD" ]; then
       error "Cannot find stable git branch. Please checkout project to a branch";
    fi

    echo "$branch"
}

function gitIsCleanState() {
    ensureFirstParamIsAPathToGit "$@"
    cd "${1}"
    
    if [ -z "$(git status --porcelain)" ]; then
        return 0
    fi
    return 1
}

function gitSetupRemoteTracking() {
    ensureFirstParamIsAPathToGit "$@"
    cd "${1}"

    git branch --set-upstream-to=origin/$(gitCurrentBranch $@)
}


function gitState() {
    ensureFirstParamIsAPathToGit "$@"
    cd "${1}"
    run git status
}

function gitSetUpstremBranch() {
    ensureFirstParamIsAPathToGit "$@"
    cd "${1}"

    local branch="$(gitCurrentBranch ${1})";
    git branch --set-upstream-to "${branch}" "origin/${branch}"
}

function gitRemoteState() {
    ensureFirstParamIsAPathToGit "$@"
    cd "${1}"

    run git fetch;

    local localKey=$(run git rev-parse @{0})
    local remoteKey=$(run git rev-parse @{u})
    local baseKey=$(run git merge-base @{0} @{u})

    if [ ! -z "${localKey}" ] && [ "${localKey}" = "${remoteKey}" ]; then
        echo "Local Branch vs. Remote Branch: Up-to-date"
        return 0
    elif [ ! -z "${localKey}" ] &&  [ "${localKey}" = "${baseKey}" ]; then
        >&2 echo "Local Branch vs. Remote Branch: Need pull"
        return 1
    elif [ ! -z "${remoteKey}" ] &&  [ "${remoteKey}" = "${baseKey}" ]; then
        >&2 echo "Local Branch vs. Remote Branch: Need push"
        return 2
    else
        >&2 echo "Local Branch vs. Remote Branch: Diverged"
        return 3
    fi
}

function gitSetupNoFastForward() {
    ensureFirstParamIsAPathToGit "$@"
    cd "${1}"

    git config branch.develop.mergeoptions "--no-ff";
}

function gitResetToOriginalState() {
    ensureFirstParamIsAPathToGit "$@"
    cd "${1}"

    if [ -z ${2+x} ]; then
        error "Missing parameter"
    fi;

    local path=${2}
    git checkout -- "${path}"
}

function gitPull() {
    ensureFirstParamIsAPathToGit "$@"

    local branch=$(gitCurrentBranch "${1}")

    cd "${1}"
    git pull origin "${branch}"
    
}

function gitCommit() {
    ensureFirstParamIsAPathToGit "$@"
    local msg="${2}"
    
    gitAddAll "${1}";
    git commit -m "${msg}"
}

function gitAddAll() {
    ensureFirstParamIsAPathToGit "$@"
    
    cd "${1}"
    git add -A
}

function gitPush() {
    local mode="${1:-}"

    ensureFirstParamIsAPathToGit "$@"

    cd "${1}"

    if [ "${mode}" == "pull-first" ]; then
        git pull origin "$(gitCurrentBranch ${1})"
    fi

    git push origin "$(gitCurrentBranch ${1})"
}

function gitCommitAndPush() {
    ensureFirstParamIsAPathToGit "$@"

    gitCommit "${@}"
    gitPush "${1}"
}

function gitResetToRemote() {
    local mode=${2:-ask}

    ensureFirstParamIsAPathToGit "$@"
    cd "${1}"

    if [ "${mode}" != "force" ] && ! gitIsCleanState "${1}"; then
        ensureCanContinue "It seems that You have uncommited changes. If You continue, they will be ERASED. Do You want to continue?"
    fi

    local branch="$(gitCurrentBranch ${1})";
    debug "Resetting repo to be in sync with origin/${branch}."


    run git fetch
    run git clean -df
    run git reset --hard HEAD
    run git reset --hard "origin/${branch}"
}

function gitCurrentRemoteUrl() {
    ensureFirstParamIsAPathToGit "$@"
    cd "${1}"

    git config --get remote.origin.url
}

function gitRemoteHash() {
    local pathToGitFolderOrUrlToRepository="${1}";

    git ls-remote ${pathToGitFolderOrUrlToRepository} -h HEAD | awk '{print $1;}'
}

function gitLocalHash() {
    ensureFirstParamIsAPathToGit "$@"
    cd "${1}"

    git log --pretty=format:'%H' -n 1
}

function ensureFirstParamIsAPathToGit() {
    if [ -z "${1+x}" ]; then
        error "Missing parameter"
    fi;

    if [ ! -d "${1}" ]; then
        error "'${1}' Must be a valid path to directory"
    fi;

    if [ ! -d "${1}/.git" ]; then
        error "'${1}' Must be a valid path to git directory"
    fi;
}

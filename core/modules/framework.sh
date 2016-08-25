#!/bin/bash

export LOG_LEVEL="${LOG_LEVEL:-2}" # 3 = debug -> 0 = error
export MAIN_PROCESS_PID=$BASHPID


# inspired by https://github.com/kvz/bash3boilerplate/blob/master/main.sh

function _fmt ()      {
  local color_ok="\x1b[32m"
  local color_bad="\x1b[31m"

  local color="${color_bad}"
  if [ "${1}" = "debug" ] || [ "${1}" = "info" ] || [ "${1}" = "notice" ]; then
    color="${color_ok}"
  fi

  local color_reset="\x1b[0m"
  if [[ "${TERM}" != "xterm"* ]] || [ -t 1 ]; then
    # Don't use colors on pipes or non-recognized terminals
    color=""; color_reset=""
  fi
  echo -e "$(date -u +"%Y-%m-%d %H:%M:%S UTC") ${color}$(printf "[%9s]" ${1})${color_reset}";
}
function debug ()     { [ "${LOG_LEVEL}" -ge 3 ] && echo "$(_fmt debug) ${@}" 1>&2 || true; }
function info ()      { [ "${LOG_LEVEL}" -ge 2 ] && echo "$(_fmt info) ${@}" 1>&2 || true; }
function warning ()   { [ "${LOG_LEVEL}" -ge 1 ] && echo "$(_fmt warning) ${@}" 1>&2 || true; }
function error () {                           
    echo "$(_fmt error) ${@}" 1>&2 || true; 

    if [[ $MAIN_PROCESS_PID == $BASHPID ]]; then
        exit 1
    else
        $(kill -9 $MAIN_PROCESS_PID > /dev/null 2>&1)
    fi
}

function parametersUsage() {
    if [[ "$(type -t usageParameters)" == "function" ]]; then
        usageParameters "${@}"
    else
        usage "${@}"
    fi
}


function printUsage() {
    local customMsg="${1:-}"
    local usageSchemeMsg="Usage for ${0}:"


    if [[ "$(type -t usageScheme)" == "function" ]]; then
        local usageSchemeMsg="$(usageScheme)"
    fi

    if [ "${customMsg}" != "" ]; then
        echo "======================================================";
        echo "${customMsg}"
    fi

    echo "======================================================";
    echo "${usageSchemeMsg}";
    echo "------------------------------------------------------";
    echo "$(usage)";
    echo "======================================================";

  exit 1
}

function cleanup_before_exit () {
  # We can clean resources here
  return 0;
}
trap cleanup_before_exit EXIT


function doAsk() {

    if [ -z ${1+x} ]; then
        error "Missing parameter 1: message"
    fi
    local msg=${1}
    
    if [ -z ${2+x} ]; then
        error "Missing parameter 2: array of available answers"
    fi
    local availableAnswers=("$2")

    local defaultValue="${3:-}"
    local userInput;

    if [ ! -z "$availableAnswers" ]; then
        msg="$msg [${availableAnswers[@]}]"
    fi

    if [ ! -z "${defaultValue}" ]; then
        msg="$msg (Default: ${defaultValue})"
    fi

    read -p "$msg: " userInput 

    if [ -z "$userInput" ]; then
        userInput="${defaultValue}"
    fi

    if ! [[ "${availableAnswers[@]}" =~ "${userInput}" ]]; then
        >&2 echo "Incorrect value '$userInput'. Can be one of: ${availableAnswers[@]}"
        return 1
    fi

    echo "$userInput";

    return 0
}

function ask() {
    set +u

    until doAsk "$@" ; do
        local dummy="1"
    done

    set -u
}

function ensureCanContinue() {
    if [ "${FORCE:-}" == "1" ]; then
        return 0
    fi


    local answer=$(ask "${1}" "yes no" ${2:-no})
    if [ "${answer}" != "yes" ]; then
        echo "QUIT"
        exit 1
    fi
}

# Function requires usage() function to work
#
# availableAnswers -d and -h are reserved
#
# function usage() must print help in exact format as in below example
#  -f   [arg] Filename to process. Required.
#  -t   [arg] Location of tempfile. Default="/tmp/bar"
#  -d         Enables debug mode
#  -h         This page
function parseArguments() {
    set +u
    set +e;

    if [ "$(type -t usage)" != "function" ]; then
        read -r -d '' exampleUsage <<-'EOF'

Please define usage() function which prints help in format exact as in below example:
----------------------------------------------------------------
  -f   [arg] Filename to process. Required.
  -t   [arg] Location of tempfile. Default="/tmp/bar"
  -d         Enables debug mode
  -h         Help
----------------------------------------------------------------
EOF
        error "${exampleUsage}"; 
    fi

    local args=("$@")
    parseArgumentAndShowHelpIfNeedTo "$@"
    if argumentsHaveAForceFlag "$@"; then
        FORCE=1
        args=(${args[@]/--force})
    fi
    doParseArguments "${args[@]}"

    set -e;
    set -u;

    if [ "${arg_h}" = "1" ]; then
        printUsage
    fi    

    if [ "${arg_d}" = "1" ]; then
      LOG_LEVEL="3"
      set -o xtrace
    fi

}

function doParseArguments() {
    local scriptName="${0}"

    # Translate usage string -> s arguments, and set $arg_<flag> defaults
    while read line; do
      line="${line}" | sed 's/^ *//g'
      if [ "${line:0:1}" != "-" ]; then
         continue;
      fi

      opt="$(echo "${line}" | awk '{print $1}' | sed -e 's#^-##')"

      if ! echo "${line}" | egrep '\[.*\]' > /dev/null 2>&1; then
        init="0" # it's a flag. init with 0
      else
        opt="${opt}:" # add : if opt has arg
        init=""  # it has an arg. init with ""
      fi
      opts="${opts}${opt}"

      varname="arg_${opt:0:1}"
      if ! echo "${line}" | egrep '\. Default=' > /dev/null 2>&1; then
        eval "${varname}=\"${init}\""
      else
        match="$(echo "${line}" |sed 's#^.*Default=\(\)#\1#g')"
        eval "${varname}=\"${match}\""
      fi
    done <<< "$(parametersUsage)"

    # Reset in case getopts has been used previously in the shell.
    OPTIND=1

    local tmpPath=$(mktemp);

    while ! inArrayArg "$(echo ${1} | sed 's/^ *//g' | cut -c1-1)" "-" " " "" ; do
        shift 1
    done

    # Overwrite $arg_<flag> defaults with the actual CLI availableAnswers
    while getopts "${opts}" opt 2> "${tmpPath}"; do
      line="$(echo "$(usage)" | grep "\-${opt}")"

      [ "${opt}" = "?" ] && printUsage "$(cat ${tmpPath})"
      varname="arg_${opt:0:1}"
      default="${!varname}"

      value="${OPTARG}"
      if [ -z "${OPTARG}" ] && [ "${default}" = "0" ]; then
        value="1"
      fi

      eval "${varname}=\"${value}\""
      debug "cli arg ${varname} = ($default) -> ${!varname}"
    done

    shift $((OPTIND-1))

    [ "$1" = "--" ] && shift

    return 0;
}

function argumentsHaveAHelpMark() {
    for element in "$@" 
    do
        if [ "${element}" == "-h" ] \
            || [ "${element}" == "/?" ] \
            || [ "${element}" == "-?" ] \
            || [ "${element}" == "--help" ]; then
            return 0;
        fi
    done 
    return 1;
}

function argumentsHaveAForceFlag() {
    for element in "$@" 
    do
        if [ "${element}" == "-f" ] \
            || [ "${element}" == "--force" ]; then
            return 0;
        fi
    done 
    return 1;
}

function parseArgumentAndShowHelpIfNeedTo() {
    if argumentsHaveAHelpMark "$@"; then
        printUsage
    fi
}

function usageError() {
    local msg=$(
        echo "${1}"
        usage
    )
    error "${msg}"
}

function run() {
    debug "$@";

    # execute
    "$@"; 
}

function runInTrap() {
    local trapCommand="${1}"
    shift 1

    trap ${trapCommand} EXIT HUP INT QUIT KILL TERM 
    if "$@"; then
        ${trapCommand}
    fi
    trap - EXIT HUP INT QUIT KILL TERM 
}

function runSilent() {
    debug "$@";
    
    if [ "${LOG_LEVEL}" = "3" ]; then
        # execute loudly
        "$@"
    else
        # execute silently
        "$@" > /dev/null 2>&1;        
    fi
}

function runMaybe() {
    local probability="${1}"
    shift 1

    if [[ ! $probability =~ ^-?[0-9]+$ ]] \
        || (( $probability > 100 )) \
        || (( $probability < 0 )); then
        error "probability must be a number between 0-100."
    fi

    if (( $(( 1 + RANDOM % 100 )) <= $probability )); then
        "$@"
    else
        debug "runMaybe skipped a command"
    fi
}



function silentPipe() {
    local outputPipe=${1-}
    
    if [ "${LOG_LEVEL}" = "3" ]; then
        # execute loudly

        if [ -z ${outputPipe} ]; then
            cat -
        else
            cat - | tee ${outputPipe}
        fi
    else
        # execute silently
        if [ -z ${outputPipe} ]; then
            cat > /dev/null 2>&1
        else
            cat > ${outputPipe}
        fi
    fi
}

function md5Hash() {
    if command -v md5sum > /dev/null 2>&1; then
        cat | md5sum | cut -f 1 -d ' '
    else
        cat | md5
    fi
}

function createTmpDir() {
    echo $( mktemp -d )
}

function inArray() {
    local search="${1}"
    local array=("${2}")

    for i in ${array[@]}; do
        if [[ "$i" == "$search" ]]; then
            return 0;
        fi
    done    
    
    return 1;
}

function inArrayArg() {
    local search="${1}"
    shift 1

    for i in "${@}"
    do
        if [[ "${i}" == "${search}" ]]; then
            return 0;
        fi
    done    
    
    return 1;
}

function remove() {
    filesRemove "${@}";
}

function copy() {
    filesCopy "${@}";
}

function move() {
    filesMove "${@}";
}

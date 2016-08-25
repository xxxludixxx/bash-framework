#!/bin/bash

function configLoad() {
    local file="${1}"
    
    configLoadByDimension "${file}" "common"
    
    configPrepareDimensions

    local dimensions=$( appDimensionsConfig )
    for dimension in ${dimensions[@]}
    do
        configLoadByDimension "${file}" "${dimension}" 
    done
}

function configLoadByDimension() {
    local file="${1}"
    local dimension="${2}"
    local currentDimension="coreCurrentDimension_${dimension}"

    coreLoad "config" "${file}" "" "${dimension}" "${!currentDimension:-}"
}


function configPrepareDimensions() {
    local dimensionsConfigFile="${BASE_DIR}/app/config/dimensions.sh";

    if [[ ! -r "${dimensionsConfigFile}" ]]; then
        local dimensions=$(appDimensionsConfig)

        for dimension in ${dimensions[@]}
        do
            local dimensionValue=$(ask "What is your ${dimension}?" "$( appDimensionsConfig_${dimension} )")

            echo "coreCurrentDimension_${dimension}=\"${dimensionValue}\"" >> "${dimensionsConfigFile}"
        done
    fi

    coreIncludeSource "${dimensionsConfigFile}"
}

function configScanDir() {
    local dir=${1}
    local reccurently=${2:-"flat"}

    if [ "${reccurently}" == "reccurently" ]; then
        find "${dir}/" | tr "\n" " "
    else    
        ls "${dir}/" | tr "\n" " "
    fi
}

function configRender() {
    local srcPath="${1}"
    local dstPath="${2}"
    shift 2;

    local content="${srcPath}"
    local isPair=0
    local lastArg
    
    for arg in "$@"
    do
        if [ ${isPair} = 1 ]; then
            content="${content//${lastArg}/${arg}}"
        fi

        isPair="$((1-isPair))"
        lastArg="${arg}"
    done

    echo "$content" > "${dstPath}"
}
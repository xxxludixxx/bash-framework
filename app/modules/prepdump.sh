
function prepdumpOptimize(){
    local opMode="${1:-}";
    local triggerUser="${arg_t}";
    local dumpFile="${arg_p}";

    if [[ "${opMode}" = "inplace" ]]; then
        prepdumpSwapTriggersUserInPlace "${triggerUser}" "${dumpFile}";
    elif [[ "${opMode}" = "pipe" ]]; then        
        systemEnsureHasActiveStream;
        prepdumpSwapTriggersUser "${triggerUser}";
    else
        printUsage "Missing arguments"
    fi
}

function prepdumpSwapTriggersUser(){
    local replacement="${1}"; 

    sed -e "s/DEFINER=\`.*\`@/DEFINER=\`"${replacement}"\`@/g";
}

function prepdumpSwapTriggersUserInPlace(){
    local replacement="${1}";
    local targetFile="${2}"; 

    sed -i "s/DEFINER=\`.*\`@/DEFINER=\`"${replacement}"\`@/g" "${targetFile}" ;
}
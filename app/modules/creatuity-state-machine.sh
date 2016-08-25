function stateMachine.push() {                                  # Pushes the given value into the stack.
    : ${1? 'Missing attribute name'}                            # Error status for missing attribute name.
    : ${2? 'Missing values(s) to push'}                         # Error status for missing value.

    local attribute="${1^^}";                                   # Function's local variables
    local value="${2^^}";                                       #
    local arrayName="STATE_MACHINE_${attribute}"                #

    if [[ $( stateMachine.exist "$arrayName" ) == 0 ]]; then
        eval "${arrayName}+=(${value})";
    else
        stateMachine.init "${arrayName}";
        eval "${arrayName}+=(${value})";
    fi
}

function stateMachine.exist() {                                 # Tests if the given array contains any values.
    : ${1? 'Missing attribute name'}                            # Error status for missing attribute name.

    local attribute="${1^^}";                                   # Function's local variables
    local arrayIndices="${!attribute[@]}"                       #

    if [[ "${arrayIndices}" == 0 ]]; then
        echo "1"
    else
        echo "0"
    fi
}

function stateMachine.init() {                                  # Initializes an array with the given attribute name.
    : ${1? 'Missing attribute name'}                            # Error status for missing attribute name.

    local attribute="${1^^}";                                   # Function's local variables
    local arrayName=STATE_MACHINE_"${attribute}";               #

    eval "${arrayName}=()"
}

function stateMachine.pop() {                                   # Pops the given value from the stack.
    : ${1? 'Missing attribute name'}                            # Error status for missing attribute name.

    local attribute="${1^^}";                                   # Function's local variables
    local arrayName="STATE_MACHINE_${attribute}";               #

    if [[ ! $( stateMachine.exist "${arrayName}" ) == 0 ]]; then
        eval "unset $arrayName[-1]"
    fi
}

function stateMachine.drop() {                                  # Drops the existing attribute array
    : ${1? 'Missing attribute name'}                            # Error status for missing attribute name

    local attribute="${1^^}";                                   # Function's local variables
    local value="${2^^}";                                       #
    local arrayName="STATE_MACHINE_${attribute}";               #

    eval "unset ${arrayName}";
}
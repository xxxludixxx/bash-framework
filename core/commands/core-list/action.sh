
# Entry point of the command
function runAction() {
    local msg=$(
        echo "Available commands:"
        echo "$( coreCommandsList list)";
    );

    info "${msg}";
}


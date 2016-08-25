
function actionUsageDescription() {
    echo ""
    echo "Downloads core to $(coreDevModmanPath) subfolder and symlinks it to Your current instnace."
    echo "This way, You will be able to develop core & Your app at the same time."
    echo "Remember! Once You done, You must commit changes for both repositories."
    echo "Fortunately, Bash Base can do it for You if You type:"
    echo "   $(coreRouterName) core-dev commit 'Message of the commit'"
}

function actionUsagePositionParameters() {
    echo "start|stop|commit|status [commit-message]"
}

function actionUsageAbove() {
    echo "Where 'start' turns on symlinks (default)";
    echo "Where 'stop' turns off symlinks";
    echo "Where 'commit' commits changes using [commit-message], AND PUSHES THEM REMOTELY (by default)";
    echo "Where 'status' shows how 'git status' would look like, without symlinks";
}

function actionUsageBelow() {
    echo " -p     push changes after 'commit'. Default=\"1\""
}


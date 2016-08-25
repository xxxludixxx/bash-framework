
function actionUsageDescription() {
    echo "Prepares and optimizes db dump file for migration to different user and database";
}

function actionUsagePositionParameters() {
    echo "pipe|inplace";
}

function actionUsageAbove() {
    echo "Where 'pipe' is a prepdump mode, where You can use linux stream";
    echo "Where 'inplace' is a prepdump mode, where You can change sql in place";
}

function actionUsageBelow() {
    echo " -t  [arg] new user for trigger";
    echo " -p  [arg] Provide path to input db dump(Only in \"inplace\" mode)";
    echo ""
    echo "Example Usages with Pipes:";
    echo '    prepdump pipe -t <New_User_Name> -p <Path/To/Source/File> | mysql <db-name> -u -h -p';
    echo '    mysqldump <db-name> -u -h -p | prepdump pipe -t <New_User_Name> | mysql <db-name> -u -h -p';
    echo "    prepdump pipe -t <New_User_Name> -p <Path/To/Dump/file> > <Path/To/Destination/File>";
    echo "Example Usages of inplace mode:";
    echo '    prepdump inplace -t <New_User_Name> -p <Path/To/Source/File>';
}


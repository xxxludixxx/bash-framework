#!/bin/bash


function mysqlCmd() {
    local warning="Warning: Using a password"

    if [[ "${mysqlScope}" == *"storehouse"* ]] && [ ! -z "${projectStorehouseSSH}" ]; then
        eval "${projectStorehouseSSH} $@" 2>&1 | grep -v "${warning}"
    else
        "$@" 2>&1 | grep -v "${warning}"
    fi
}

function mysqlDump() {
    if [ -z ${1+x} ]; then
        error "Missing parameter"
    fi
    
    mysqlFetchCredentials "${1}";

    debug "Dumping ${mysqlUri}...";
    run mysqlCmd mysqldump -h"${mysqlHost}" -u"${mysqlUser}" -p"${mysqlPswd}" "${mysqlName}"

    return $?;
}

function mysqlRecreate() {
    if [ -z ${1+x} ]; then
        error "Missing parameter"
    fi
    
    mysqlFetchCredentials "${1}";
    
    debug "Dropping ${mysqlUri}...";

    runSilent mysqlCmd mysqladmin --force -h"${mysqlHost}" -u"${mysqlUser}" -p"${mysqlPswd}" drop  "${mysqlName}" || true;

    debug "Creating ${mysqlUri}...";
    runSilent mysqlCmd mysqladmin --force -h"${mysqlHost}" -u"${mysqlUser}" -p"${mysqlPswd}" create "${mysqlName}";
    
    info "Database ${mysqlUri} recreated (dropped old and created empty one)."
    return 0;
}

function mysqlRunSql() {
    if [ -z ${1+x} ]; then
        error "Missing parameter"
    fi
    
    mysqlFetchCredentials "${1}";

    if [ -z ${2+x} ]; then
        debug "Executing sql on ${mysqlUri}...";
        run mysqlCmd mysql -h"${mysqlHost}" -u"${mysqlUser}" -p"${mysqlPswd}" -D "${mysqlName}";
    else
        debug "Executing sql on ${mysqlUri}: ${2}";
        echo "${2}" | run mysqlCmd mysql -h"${mysqlHost}" -u"${mysqlUser}" -p"${mysqlPswd}" -D "${mysqlName}";
    fi
}

function mysqlClone() {
    if [ -z ${1+x} ] || [ -z ${2+x} ]; then
        error "Missing parameter"
    fi

    srcUri=$(mysqlUriOf ${1})
    dstUri=$(mysqlUriOf ${2})

    if [ "${1}" = "${2}" ]; then
        warning "Cloning ${srcUri} to ${dstUri} skiped, because it is the same"
        return 0
    fi

    mysqlRecreate "${2}"
    
    info "Cloning ${srcUri} to ${dstUri}..."
    mysqlDump "${1}" | grep -v "Using a password on the command line interface can be insecure" | mysqlRunSql "${2}" 
}

function mysqlUpdateCredentials() {
    if [ -z ${1+x} ] || [ -z ${2+x} ] || [ -z ${3+x} ]  ; then
        error "Missing parameter"
    fi

    eval "${2}_${1}=\"${3}\"" 
}

function mysqlFetchCredentials() {
    if [ -z ${1+x} ]; then
        error "Missing parameter"
    fi

    mysqlHostVarName="projectMysqlHost_${1}"
    mysqlHost=${!mysqlHostVarName};

    mysqlNameVarName="projectMysqlName_${1}"
    mysqlName=${!mysqlNameVarName};

    mysqlUserVarName="projectMysqlUser_${1}"
    mysqlUser=${!mysqlUserVarName};

    mysqlPswdVarName="projectMysqlPswd_${1}"
    mysqlPswd=${!mysqlPswdVarName};

    mysqlScope="${1}"

    mysqlUri=$(mysqlUriOf ${1})

    return 0;
}

function mysqlUriOf() {
    if [ -z ${1+x} ]; then
        error "Missing parameter"
    fi

    local hostVarName="projectMysqlHost_${1}"
    local host=${!hostVarName};

    local nameVarName="projectMysqlName_${1}"
    local name=${!nameVarName};

    local userVarName="projectMysqlUser_${1}"
    local user=${!userVarName};

    echo "${user}@${host}:${name}";
}

function mysqlDbExists() {
    if [ -z ${1+x} ]; then
        error "Missing parameter"
    fi
    
    runSilent mysqlRunSql "${1}" "SHOW TABLES"
}

function mysqlDumpTableToCsvFile() {
    local databaseName=${1}
    local tableName=${2}
    local csvPath=${3}
    
    rm -rf "${csvPath}";

    info "Dumping '${tableName}' table to '${csvPath}'..."
    
    local sql=$(
        echo "SELECT * FROM ${tableName}"
        echo "INTO OUTFILE '${csvPath}'"
        echo "FIELDS TERMINATED BY ','"
        echo "ENCLOSED BY '\"'"
        echo "LINES TERMINATED BY '\n';"
    );

    mysqlRunSql "${databaseName}" "$sql";
}

function mysqlFetchCsv() {
    local databaseName=${1}
    local dbTable=${2}
    local csvPath=${3}
    local truncateData=${4:-"truncate_data"}

    if [ "${truncateData}" == "truncate_data" ]; then
        info "Removing all entries from '${dbTable}'..."
        runSilent mysqlRunSql "${databaseName}" "TRUNCATE TABLE ${dbTable}" \
            || mysqlRunSql "${databaseName}" "DELETE FROM ${dbTable}"
    fi

    info "Populating '${dbTable}' table by '${csvPath}'..."

    local sql=$(
        echo "SET FOREIGN_KEY_CHECKS = 0;"

        echo "LOAD DATA LOCAL INFILE '${csvPath}' "
        echo "INTO TABLE ${dbTable} "
        echo "FIELDS TERMINATED BY ',' "
        echo "ENCLOSED BY '\"' "
        echo "LINES TERMINATED BY '\n'; "

        echo "SET FOREIGN_KEY_CHECKS = 1;"
    );

    mysqlRunSql "${databaseName}" "${sql}"
}

function appInstall() {

    systemInstallTo
    systemRegisterCLICommand
    systemRegisterCLICommand "admin-prepdump" "admin-prepdump.sh"

    info "Successfuly installed to $(systemInstallDir)"
}

function appUninstall() {

    systemUnregisterCLICommand "admin-prepdump"
    systemUnregisterCLICommand
    systemUninstallFrom

    info "Successfuly uninstalled"
}

    
cd /tmp \
    && rm -rf admin-tools \
    && git clone ssh://git@stash.creatuity.net:7999/intcb/admin-tools.git \
    && admin-tools/run.sh uninstall --force \
    && admin-tools/run.sh install --force \
    && rm -rf admin-tools/

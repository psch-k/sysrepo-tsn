#!/bin/bash

set -eu -o pipefail

shopt -s failglob

local_path=$(dirname $0)

: ${SYSREPOCTL:=sysrepoctl}
: ${SYSREPOCFG:=sysrepocfg}
OWNER=$(id -un)
GROUP=$(id -gn ${OWNER})
SYSREPOCTL_ROOT_PERMS="-o ${OWNER} -g ${GROUP} -p 600"
: ${YANG_DIR:=$local_path/../modules}

is_yang_module_installed() {
    module=$1

    $SYSREPOCTL -l | grep -c "^$module [^|]*|[^|]*| I .*$" > /dev/null
}

install_yang_module() {
    yang_file=$1
    module="${yang_file%%@[-0-9]*}"

    if ! is_yang_module_installed $module; then
        echo "- Installing module $module..."
        $SYSREPOCTL -i ${YANG_DIR}/${yang_file}.yang -s "${YANG_DIR}" -v 2
        $SYSREPOCTL -c $module $SYSREPOCTL_ROOT_PERMS
    else
        echo "- Module ${yang_file} already installed."
    fi
}

enable_yang_module_feature() {
    module=$1
    feature=$2

    if ! $SYSREPOCTL -l | grep -c "^$module [^|]*|[^|]*|[^|]*|[^|]*|[^|]*|[^|]*|.* $feature.*$" > /dev/null; then
        echo "- Enabling feature $feature in $module..."
        $SYSREPOCTL -c $module -e $feature
    else
        echo "- Feature $feature in $module already enabled."
    fi
}


install_yang_module iana-if-type@2017-01-19

install_yang_module ietf-interfaces@2018-02-20
install_yang_module ieee802-dot1q-types
install_yang_module ieee802-ethernet-interface

install_yang_module ieee802-dot1q-preemption
enable_yang_module_feature ieee802-dot1q-preemption frame-preemption

install_yang_module ieee802-dot1q-sched
enable_yang_module_feature ieee802-dot1q-sched scheduled-traffic

install_yang_module ieee802-dot1q-bridge
install_yang_module ietf-yang-types@2013-07-15
install_yang_module ieee802-types
install_yang_module ietf-inet-types@2013-07-15
install_yang_module ieee802-dot1q-stream-filters-gates
enable_yang_module_feature ieee802-dot1q-stream-filters-gates closed-gate-state
install_yang_module ieee802-dot1q-psfp
install_yang_module ieee802-dot1q-cb-stream-identification
install_yang_module ieee802-dot1q-qci-augment

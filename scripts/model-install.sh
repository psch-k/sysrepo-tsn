#!/bin/bash

set -eu -o pipefail

shopt -s failglob

local_path=$(dirname $0)

: ${SYSREPOCTL:=sysrepoctl}
: ${SYSREPOCFG:=sysrepocfg}
: ${SYSREPOCTL_ROOT_PERMS:=-o root:root -p 600}
: ${YANG_DIR:=$local_path/../modules}

is_yang_module_installed() {
    module=$1

    $SYSREPOCTL -l | grep --count "^$module [^|]*|[^|]*| Installed .*$" > /dev/null
}

install_yang_module() {
    module=$1

    if ! is_yang_module_installed $module; then
        echo "- Installing module $module..."
        $SYSREPOCTL -i -g ${YANG_DIR}/$module.yang $SYSREPOCTL_ROOT_PERMS
    else
        echo "- Module $module already installed."
    fi
}

enable_yang_module_feature() {
    module=$1
    feature=$2

    if ! $SYSREPOCTL -l | grep --count "^$module [^|]*|[^|]*|[^|]*|[^|]*|[^|]*|[^|]*|.* $feature.*$" > /dev/null; then
        echo "- Enabling feature $feature in $module..."
        $SYSREPOCTL -m $module -e $feature
    else
        echo "- Feature $feature in $module already enabled."
    fi
}

mkdir -p "${YANG_DIR}"
GITHUB_YANG_ROUT_URL="https://raw.githubusercontent.com/YangModels/yang/master/standard"

[ ! -r "${YANG_DIR}/ietf-interfaces@2014-05-08.yang" ] && \
	wget -P "${YANG_DIR}" "${GITHUB_YANG_ROUT_URL}/ietf/RFC/ietf-interfaces@2014-05-08.yang"
[ ! -r "${YANG_DIR}/ieee802-dot1q-types.yang" ] && \
	wget -P "${YANG_DIR}" "${GITHUB_YANG_ROUT_URL}/ieee/draft/802.1/Qcw/ieee802-dot1q-types.yang"
[ ! -r "${YANG_DIR}/ieee802-dot1q-preemption.yang" ] && \
	wget -P "${YANG_DIR}" "${GITHUB_YANG_ROUT_URL}/ieee/draft/802.1/Qcw/ieee802-dot1q-preemption.yang"
[ ! -r "${YANG_DIR}/ieee802-dot1q-sched.yang" ] && \
	wget -P "${YANG_DIR}" "${GITHUB_YANG_ROUT_URL}/ieee/draft/802.1/Qcw/ieee802-dot1q-sched.yang"
[ ! -r "${YANG_DIR}/iana-if-type@2017-01-19.yang" ] && \
	wget -P "${YANG_DIR}" "${GITHUB_YANG_ROUT_URL}/ietf/RFC/iana-if-type@2017-01-19.yang"
[ ! -r "${YANG_DIR}/ieee802-dot1q-bridge.yang" ] && \
	wget -P "${YANG_DIR}" "${GITHUB_YANG_ROUT_URL}/ieee/published/802.1/ieee802-dot1q-bridge.yang"
[ ! -r "${YANG_DIR}/ietf-yang-types@2013-07-15.yang" ] && \
	wget -P "${YANG_DIR}" "${GITHUB_YANG_ROUT_URL}/ietf/RFC/ietf-yang-types@2013-07-15.yang"
[ ! -r "${YANG_DIR}/ieee802-types.yang" ] && \
	wget -P "${YANG_DIR}" "${GITHUB_YANG_ROUT_URL}/ieee/draft/802.1/Qcw/ieee802-types.yang"
[ ! -r "${YANG_DIR}/ietf-inet-types@2013-07-15.yang" ] && \
	wget -P "${YANG_DIR}" "${GITHUB_YANG_ROUT_URL}/ietf/RFC/ietf-inet-types@2013-07-15.yang"
[ ! -r "${YANG_DIR}/ieee802-dot1q-stream-filters-gates.yang" ] && \
	wget -P "${YANG_DIR}" "${GITHUB_YANG_ROUT_URL}/ieee/draft/802.1/Qcr/ieee802-dot1q-stream-filters-gates.yang"
[ ! -r "${YANG_DIR}/ieee802-dot1q-psfp.yang" ] && \
	wget -P "${YANG_DIR}" "${GITHUB_YANG_ROUT_URL}/ieee/draft/802.1/Qcw/ieee802-dot1q-psfp.yang"


install_yang_module iana-if-type@2017-01-19

install_yang_module ietf-interfaces@2014-05-08
install_yang_module ieee802-dot1q-types
install_yang_module ieee802-dot1q-preemption
enable_yang_module_feature ieee802-dot1q-preemption frame-preemption

install_yang_module ieee802-dot1q-sched
enable_yang_module_feature ieee802-dot1q-sched scheduled-traffic

install_yang_module iana-if-type@2017-01-19

install_yang_module ieee802-dot1q-bridge
install_yang_module ietf-yang-types
install_yang_module ieee802-types
install_yang_module ietf-inet-types@2013-07-15
install_yang_module ieee802-dot1q-stream-filters-gates
enable_yang_module_feature ieee802-dot1q-stream-filters-gates closed-gate-state
install_yang_module ieee802-dot1q-psfp
install_yang_module ieee802-dot1q-cb-stream-identification
install_yang_module ieee802-dot1q-qci-augment

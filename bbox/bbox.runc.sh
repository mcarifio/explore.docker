#!/usr/bin/env bash


path.pn () ( realpath -Lms ${1:-${PWD}}; )
path.md () (
    : '${folder} #> make a directory (md) and return its pathname, e.g cp foo $(path.md /tmp/foo)/bar';
    local _d="$(path.pn ${1:?"${FUNCNAME} expecting a directory"})"
    [[ -d "$_d" ]] || mkdir -p "${_d}";
    printf "%s" "${_d}"
)


main() (
    local _here="$(realpath -Lm $(dirname $0))"
    local _rootfs=${1:-rootfs}
    docker export $(docker create busybox) | tar xf - -C $(path.md ${_here}/${_rootfs})
    # runc spec ## creates config.json
    # show what you'll run
    jq .process.args ${_here}/config.json
    (set -x; sudo runc run --bundle ${_here} ${_rootfs})
)


main "${@:-}"

#!/bin/bash

: ${ARM_GROUP_NAME_WHAT_I_REALLY_WANT_TO_DELETE:?Resource group name required}

set -eo pipefail

main() {
    echo "Destroying $ARM_GROUP_NAME_WHAT_I_REALLY_WANT_TO_DELETE. Press ^C to abort."
    sleep 5
    azure group delete $ARM_GROUP_NAME_WHAT_I_REALLY_WANT_TO_DELETE -q
}

if [[ "$0" == "$BASH_SOURCE" ]]; then
    main "$@"
fi
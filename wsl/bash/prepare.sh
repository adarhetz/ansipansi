#!/bin/bash

set -euo pipefail
DIR_ME=$(realpath "$(dirname "$0")")

# this script is called by root an must fail if no user is provided
. "${DIR_ME}/.userfoo.sh"
setUserName ${1-""}
OS_TYPE=${2-"ubuntu"}

virtualEnvName='default'
sudo apt install python3-pip virtualenv git curl -y
virtualenv "${HOMEDIR}/.virtualenvs/${virtualEnvName}"

virtualEnvEntry=". \"\${HOME}/.virtualenvs/${virtualEnvName}/bin/activate\""
modifyBashrc "${virtualEnvEntry}" "${virtualEnvEntry}"

( . "${HOMEDIR}/.virtualenvs/${virtualEnvName}/bin/activate" && pip install ansible )

runFunctionName='runAnsipansi'
runFunction="runAnsipansi() { . \${HOME}/.virtualenvs/${virtualEnvName}/bin/activate && ansible-playbook '$( realpath "${DIR_ME}/../ansible/playbook.yaml")'; }"
modifyBashrc "${runFunctionName}" "${runFunction}"

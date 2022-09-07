#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail

tfenv install
tfenv use

tgenv install $(cat .terragrunt-version)
tgenv use $(cat .terragrunt-version)

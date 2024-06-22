#!/bin/bash
set -e

echo "--> Generating doc"
rm -f .terraform.lock.hcl

mods=$(find modules/* -type d -maxdepth 0)
for mod in $mods; do
  pushd $mod
  terraform-docs -c .terraform-docs.yml .
  popd
done

#/bin/bash

set -e

if ! command -v gum &> /dev/null
then
    echo "gum could not be found, please install it first."
    exit
fi

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[1]}" )" && pwd )"

MOD_NAME=${1-"$(gum input --placeholder "Input module name")"}

MOD_PATH="${BASE_DIR}/modules/${MOD_NAME}"
EXAMPLES_PATH="${MOD_PATH}/examples/default"

SCAFFOLD_FILES=(main.tf outputs.tf variables.tf)
TEMPLATE_FILES=(provider.tf)

echo "--> Creating: $MOD_PATH"
echo "--> Scaffolding ${SCAFFOLD_FILES[*]}"
mkdir -p $MOD_PATH $EXAMPLES_PATH

pushd $MOD_PATH 1>/dev/null
touch "README.md"
cp $BASE_DIR/templates/provider.tf $MOD_PATH

for file in ${SCAFFOLD_FILES[*]}; do
    touch $file
done
popd 1>/dev/null

pushd $EXAMPLES_PATH 1>/dev/null
cp $BASE_DIR/templates/.terraform-docs.yml $MOD_PATH
cp $BASE_DIR/templates/provider.tf $EXAMPLES_PATH

cat << EOF >> provider.tf
provider "azurerm" {
  features {}
}
EOF

for file in ${SCAFFOLD_FILES[*]}; do
    touch $file
done
popd 1>/dev/null

#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 3 ]]; then
  echo "Usage: $0 <env.name> <aws.region> <app.name>"
  echo "Example: $0 test eu-north-1 idlms-app"
  exit 1
fi

ENV_NAME="$1"
AWS_REGION="$2"
APP_NAME="$3"

TEMPLATE_DIR="template"  
DEST_DIR="$ENV_NAME"     

if [[ ! -d "$TEMPLATE_DIR" ]]; then
  echo "ERROR: Template folder '$TEMPLATE_DIR' not found." >&2
  exit 1
fi
if [[ -e "$DEST_DIR" ]]; then
  echo "ERROR: '$DEST_DIR' already exists. Refusing to overwrite." >&2
  exit 1
fi

echo "Creating environment folder: $DEST_DIR"
mkdir -p "$DEST_DIR"
cp -a "$TEMPLATE_DIR"/. "$DEST_DIR"/

cd "$DEST_DIR"
echo "Now working in: $(pwd)"

if sed --version >/dev/null 2>&1; then
  SED_INPLACE=(sed -i)      
else
  SED_INPLACE=(sed -i '')  
fi

ENV_REPL="${ENV_NAME//&/\\&}"
REGION_REPL="${AWS_REGION//&/\\&}"
APP_REPL="${APP_NAME//&/\\&}"

echo "Replacing placeholders only in env.tfvars:"
echo "  {{env.name}}   -> $ENV_NAME"
echo "  {{aws.region}} -> $AWS_REGION"
echo "  {{app.name}}   -> $APP_NAME"

find . -type f -name "env.tfvars" -print0 \
| xargs -0 "${SED_INPLACE[@]}" \
    -e "s|{{env\.name}}|$ENV_REPL|g" \
    -e "s|{{aws\.region}}|$REGION_REPL|g" \
    -e "s|{{app\.name}}|$APP_REPL|g"

echo "Renaming env.tfvars files to ${ENV_NAME}.tfvars..."
find . -type f -name "env.tfvars" -print0 \
| while IFS= read -r -d '' file; do
    dir=$(dirname "$file")
    mv "$file" "$dir/${ENV_NAME}.tfvars"
done

COUNT=$(find . -type f -name "${ENV_NAME}.tfvars" | wc -l | tr -d ' ')

echo "Done! Updated and renamed $COUNT ${ENV_NAME}.tfvars file(s)."

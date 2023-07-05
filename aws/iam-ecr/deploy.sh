#!/bin/bash

set -o errexit
# set -o xtrace

if [[ -z "$ENV" ]]; then
  echo 'ENV environment variable is not set. Please set to "dev" or "test" or "prod".'
  exit 1
fi

TARGET_TEMPLATE=template.yml
TEMPLATE_PARMS=template.parms.yml

TEMPLATE_VERSION=$(rain fmt --json $TARGET_TEMPLATE | jq -r ".Metadata.Version")
STACK_NAME=$(rain fmt --json $TARGET_TEMPLATE | jq -r ".Metadata.RecommendedStackName")

STACK_NAME=$(eval "echo $STACK_NAME")

echo "########## PROPERTIES ##########"
echo "AWS_PROFILE: $AWS_PROFILE"
echo "Template: $TARGET_TEMPLATE"
echo "Depoying/Updating stack: $STACK_NAME"
echo "Deploying template version: $TEMPLATE_VERSION"

echo "########## LINT ##########"
cfn-lint $TARGET_TEMPLATE

echo "########## DEPLOY ##########"
rain deploy $TARGET_TEMPLATE $STACK_NAME \
    --yes \
    --termination-protection \
    --params VersionParam=$TEMPLATE_VERSION,EnvironmentParam="$ENV" \
    --config $TEMPLATE_PARMS

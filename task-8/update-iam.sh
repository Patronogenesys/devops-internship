#!/bin/bash 

ROOT_DIR=`git rev-parse --show-toplevel`

token=`cat "$ROOT_DIR/.secret/ya-oauth.json" | jq .token`
touch "$ROOT_DIR/.secret/iam.json"
curl \
  --request POST \
  --data  "{\"yandexPassportOauthToken\":$token}" \
  https://iam.api.cloud.yandex.net/iam/v1/tokens | tee "$ROOT_DIR/.secret/iam.json"
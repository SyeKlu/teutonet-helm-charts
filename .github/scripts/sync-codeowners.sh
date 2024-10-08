#!/usr/bin/env bash

[[ "$RUNNER_DEBUG" == 1 ]] && set -x
[[ -o xtrace ]] && export RUNNER_DEBUG=1

echo "* @teutonet/k8s"
echo ".github/* @cwrau @marvinWolff @tasches"

for DIR in charts/*; do
  [[ -f "$DIR/Chart.yaml" ]] || continue
  FILE="$DIR/Chart.yaml"
  DIR="${DIR//\./}"
  MAINTAINERS="$(yq e '.maintainers.[].name' "$FILE" | sed 's/^/@/' | sort --ignore-case | tr '\r\n' ' ')"
  echo -e "$DIR/ $MAINTAINERS @teutonet-bot"
done | sort

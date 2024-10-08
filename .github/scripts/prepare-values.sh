#!/usr/bin/env bash

[[ "$RUNNER_DEBUG" == 1 ]] && set -x
[[ -o xtrace ]] && export RUNNER_DEBUG=1

function mergeYaml() {
  local valuesFile="${1?}"
  local overrideJson="${2?}"
  (
    yq <"$valuesFile"
    echo "$overrideJson"
  ) | jq -s 'reduce .[] as $item ({}; . * $item)' | yq -y
}

function prepare-values() {
  local chart="${1?}"
  local commonValues
  local values
  local valuesScript
  if [[ -f "$chart/ci/_common.sh" ]]; then
    commonValues="$("$chart/ci/_common.sh")"
    values="$chart/values.yaml"
    mergeYaml "$values" "$commonValues" | sponge "$values"
    if [[ "$RUNNER_DEBUG" == 1 ]]; then
      cat "$values" >&2
    fi
  fi
  for valuesScript in "$chart/ci/"*-gen-values.sh; do
    [[ -f "$valuesScript" ]] || continue
    values="${valuesScript/.sh/.yaml}"
    "$valuesScript" | yq -y | sponge "$values"
    if [[ "$RUNNER_DEBUG" == 1 ]]; then
      cat "$values" >&2
    fi
  done
}

set -ex
if [[ -v 1 ]]; then
  prepare-values "$1"
else
  for chart in charts/*; do
    [[ -d "$chart" ]] || continue
    prepare-values "$chart"
  done
fi

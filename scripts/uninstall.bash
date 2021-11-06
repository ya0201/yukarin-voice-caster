#!/usr/bin/env bash

PREFIX='yukarin-voice-caster-'

function main() {
  local systemd_dir="/etc/systemd/system"

  local routines_yaml="$(cat routines.yaml)"
  local len=$(python3 -c 'import sys, yaml; y=yaml.safe_load(sys.stdin.read()); print(len(y))' <<< "$routines_yaml")

  [[ $len -le 0 ]] && return 0
  for i in $( seq 0 $((len - 1)) ); do
    local name=$(python3 -c "import sys, yaml; y=yaml.safe_load(sys.stdin.read()); print(y[$i]['name'])" <<< "$routines_yaml")

    sudo systemctl disable ${PREFIX}${name}.service
    sudo rm -f ${systemd_dir}/${PREFIX}${name}.service
    sudo systemctl disable ${PREFIX}${name}.timer
    sudo rm -f ${systemd_dir}/${PREFIX}${name}.timer
  done

  sudo systemctl daemon-reload
  sudo systemctl reset-failed
}

main

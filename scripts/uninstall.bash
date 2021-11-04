#!/usr/bin/env bash

PREFIX='yukarin-voice-caster-'

function main() {
  local systemd_dir="/etc/systemd/system"

  local routines_yaml="$(cat routines.yaml)"
  local name_lines=$(grep 'name:' <<< "$routines_yaml")
  local len=$(wc -l <<< "$name_lines")

  [[ $len -le 0 ]] && return 0
  for i in $( seq 0 $((len - 1)) ); do
    local name=$(awk -v i=$i 'NR==i+1' <<< "$name_lines" | sed -ne "s;- name: '\(.*\)';\1;p")

    sudo systemctl disable ${PREFIX}${name}.service
    sudo rm -f ${systemd_dir}/${PREFIX}${name}.service
    sudo systemctl disable ${PREFIX}${name}.timer
    sudo rm -f ${systemd_dir}/${PREFIX}${name}.timer
  done

  sudo systemctl daemon-reload
  sudo systemctl reset-failed
}

main

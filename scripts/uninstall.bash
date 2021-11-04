#!/usr/bin/env bash

PREFIX='yukarin-voice-caster-'

function main() {
  local user_systemd_dir="${HOME}/.config/systemd/user"

  local routines_yaml="$(cat routines.yaml)"
  local name_lines=$(grep 'name:' <<< "$routines_yaml")
  local len=$(wc -l <<< "$name_lines")

  [[ $len -le 0 ]] && return 0
  for i in $( seq 0 $((len - 1)) ); do
    local name=$(awk -v i=$i 'NR==i+1' <<< "$name_lines" | sed -ne "s;- name: '\(.*\)';\1;p")

    systemctl --user disable ${PREFIX}${name}.service
    rm ${user_systemd_dir}/${PREFIX}${name}.service
    systemctl --user disable ${PREFIX}${name}.timer
    rm ${user_systemd_dir}/${PREFIX}${name}.timer
  done

  systemctl --user daemon-reload
}

main

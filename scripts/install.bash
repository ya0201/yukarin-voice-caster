#!/usr/bin/env bash

PREFIX='yukarin-voice-caster-'

function generate_service() {
  local name="$1"
  local user_systemd_dir="$2"

  cat <<EOS > ${user_systemd_dir}/${PREFIX}${name}.service
[Unit]
Description=${PREFIX}${name}.service: the service to play yukarin ${name} voice

[Service]
Type=oneshot
EnvironmentFile=$(pwd)/.env
ExecStart=$(pwd)/main.py ${name}.mp3

[Install]
WantedBy=multi-user.target
EOS
}

function generate_timer() {
  local name="$1"
  local user_systemd_dir="$2"
  local onCalendar="$3"

  cat <<EOS > ${user_systemd_dir}/${PREFIX}${name}.timer
[Unit]
Description=${PREFIX}${name}.timer: triggers ${PREFIX}${name}.service

[Timer]
OnCalendar=${onCalendar}

[Install]
WantedBy=timers.target
EOS
}

function main() {
  local user_systemd_dir="${HOME}/.config/systemd/user"
  mkdir -p $user_systemd_dir

  local routines_yaml="$(cat routines.yaml)"
  local name_lines=$(grep 'name:' <<< "$routines_yaml")
  local onCalendar_lines=$(grep 'onCalendar: ' <<< "$routines_yaml")
  local len=$(wc -l <<< "$name_lines")

  [[ $len -le 0 ]] && return 0
  for i in $( seq 0 $((len - 1)) ); do
    local name=$(awk -v i=$i 'NR==i+1' <<< "$name_lines" | sed -ne "s;- name: '\(.*\)';\1;p")
    local onCalendar=$(awk -v i=$i 'NR==i+1' <<< "$onCalendar_lines" | sed -ne "s;  onCalendar: '\(.*\)';\1;p")

    generate_service "$name" "$user_systemd_dir"
    systemctl --user enable ${PREFIX}${name}.service
    generate_timer "$name" "$user_systemd_dir" "$onCalendar"
    systemctl --user enable ${PREFIX}${name}.timer
  done

  systemctl --user daemon-reload
}

main

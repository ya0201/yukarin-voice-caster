#!/usr/bin/env bash

PREFIX='yukarin-voice-caster-'

function generate_service() {
  local name="$1"
  local systemd_dir="$2"

  sudo tee ${systemd_dir}/${PREFIX}${name}.service <<EOS
[Unit]
Description=${PREFIX}${name}.service: the service to play yukarin ${name} voice

[Service]
Type=oneshot
EnvironmentFile=$(pwd)/.env
ExecStart=$(pwd)/main.py ${name}.mp3
User=${USER}

[Install]
WantedBy=multi-user.target
EOS
}

function generate_timer() {
  local name="$1"
  local systemd_dir="$2"
  local onCalendar="$3"

  sudo tee ${systemd_dir}/${PREFIX}${name}.timer <<EOS
[Unit]
Description=${PREFIX}${name}.timer: triggers ${PREFIX}${name}.service

[Timer]
OnCalendar=${onCalendar}

[Install]
WantedBy=timers.target
EOS
}

function main() {
  local systemd_dir="/etc/systemd/system"

  local routines_yaml="$(cat routines.yaml)"
  local len=$(python3 -c 'import sys, yaml; y=yaml.safe_load(sys.stdin.read()); print(len(y))' <<< "$routines_yaml")

  [[ $len -le 0 ]] && return 0
  for i in $( seq 0 $((len - 1)) ); do
    local name=$(python3 -c "import sys, yaml; y=yaml.safe_load(sys.stdin.read()); print(y[$i]['name'])" <<< "$routines_yaml")
    local onCalendar=$(python3 -c "import sys, yaml; y=yaml.safe_load(sys.stdin.read()); print(y[$i]['onCalendar'])" <<< "$routines_yaml")

    generate_service "$name" "$systemd_dir"
    sudo systemctl enable ${PREFIX}${name}.service
    generate_timer "$name" "$systemd_dir" "$onCalendar"
    sudo systemctl enable ${PREFIX}${name}.timer
    sudo systemctl start ${PREFIX}${name}.timer
  done

  sudo systemctl daemon-reload
}

main

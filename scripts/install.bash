#!/usr/bin/env bash

mkdir -p ${HOME}/.config/systemd/user
cp ./services/yukarin-voice-caster* ${HOME}/.config/systemd/user

for f in services/*.service; do
  systemctl --user enable $(basename $f)
done
for f in services/*.timer; do
  systemctl --user enable $(basename $f)
done

systemctl --user daemon-reload

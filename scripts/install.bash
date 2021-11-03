#!/usr/bin/env bash

mkdir -p ${HOME}/.config/systemd/user
cp ./services/yukarin-voice-caster* ${HOME}/.config/systemd/user
for f in $(find services -name *.timer); do
  systemctl --user enable $(basename $f)
done

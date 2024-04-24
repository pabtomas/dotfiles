#!/bin/sh

export "$(dbus-launch)"
set -- $(gsettings get org.gnome.settings-daemon.plugins.color night-light-temperature)
if [ ${2} -ne 5500 ]
then
  gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature 5500
fi

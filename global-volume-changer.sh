#!/bin/bash

#--IMPORTANT--- Change this to some text unique to your audio device.
# You can run 'pactl list short sinks' then pick a descriptive part of the name of your audio output device, such as the name.
# For example, if my desired output is "alsa_output.usb-Razer_Razer_Kraken_Ultimate_00000000-00.analog-stereo", then I can use "Razer_Kraken_Ultimate" for the sink descriptor.
sink_descriptor=""

# Precentage to raise/lower volume by
volume_interval=5

# Maximum volume precentage
volume_max=100

# --- Script Logic ---

new_volume=""

sink_name=$(pactl list short sinks | grep $sink_descriptor | awk '{print $2}')

if [ -z $sink_name ]; then
    echo "Error, no sink with descriptor '$sink_descriptor' could be found."
    exit 1
fi

current_volume=$(pactl get-sink-volume $sink_name | awk '{print $5}' | tr -d '%')

if [ "$1" = "raise" ]; then
    new_volume="$((current_volume + volume_interval))"

    pactl set-sink-mute "$sink_name" 0

    if [ "$new_volume" -gt "$volume_max" ]; then
        pactl set-sink-volume "$sink_name" "$volume_max%"
    else
        pactl set-sink-volume "$sink_name" "$new_volume%"
    fi
elif [ "$1" = "lower" ]; then
    new_volume="$((current_volume - volume_interval))"

    if [ "$new_volume" -le 0 ]; then
        pactl set-sink-volume "$sink_name" 0
        pactl set-sink-mute "$sink_name" 1
    else
        pactl set-sink-volume "$sink_name" "$new_volume%"
    fi
else
    echo "Invalid operation. Please use 'raise' or 'lower'"
    exit 1
fi

# --- Volume change notification for KDE Plasma ---
# KDE Plamsma users can uncomment the code below to enable the OSD notification and sound effect that occurs when changing volume.

#paplay -d "$sink_name" /usr/share/sounds/freedesktop/stereo/audio-volume-change.oga
#qdbus org.kde.plasmashell /org/kde/osdService org.kde.osdService.volumeChanged $new_volume $volume_max

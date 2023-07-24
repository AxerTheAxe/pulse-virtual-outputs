#!/bin/bash

#--IMPORTANT--- Change this to some text unique to your audio device.
# You can run 'pactl list short sinks' then pick a descriptive part of the name of your audio output device, such as the name.
# For example, if my desired output is "alsa_output.usb-Razer_Razer_Kraken_Ultimate_00000000-00.analog-stereo", then I can use "Razer_Kraken_Ultimate" for the sink descriptor.
sink_descriptor=""

# Wait until the 'pactl' command is ready for use and fail if it takes too long
wait_for_pactl() {
    max_attemps=10
    attempt=0

    while [ $attempt -le $max_attemps ]; do
        if pactl list short sinks | grep "$sink_descriptor"; then
            break
        fi

        sleep 1
        attempt=$((attempt + 1))
    done
}

# Get index of the specified loaded module
get_module_index() {
    local name=$1
    pactl list short modules | awk -v name="$name" '$3 ~ name {print $1}'
}

# Create new sinks
create_virtual_output() {
    local name=$1

    if ! pactl list short sinks | grep $name; then
        pactl load-module module-combine-sink sink_name=$name slaves=$sink_name
    else
	module_index=$(get_module_index "$name")

        echo -e "\e[33mWarning, reloading '$name' because an output with that name was already found.\e[0m"

	pactl unload-module "$module_index"
        pactl load-module module-combine-sink sink_name=$name slaves=$sink_name
    fi
}

wait_for_pactl

sink_name=$(pactl list short sinks | grep $sink_descriptor | awk '{print $2}')

if [ -z $sink_name ]; then
    echo -e "\e[31mError, no sink with descriptor '$sink_descriptor' could be found.\e[0m"
    exit 1
fi

# --- Set new virtual outputs ---
# create_virtual_output OUTPUT_NAME
create_virtual_output Desktop-Output

create_virtual_output Virtual-Output-1

pactl set-default-sink Desktop-Output

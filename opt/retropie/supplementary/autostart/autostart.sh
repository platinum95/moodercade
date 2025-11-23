#!/bin/bash
user="platinum95"

home="$(eval echo ~$user)"
retropie_path="$home/RetroPie"
autostart_path="$retropie_path/autostart.rc"
runcmd="/opt/retropie/supplementary/runcommand/runcommand.sh"
ports_sys="ports"

# Preload retroarch/ES to limit time between when splash is gone and emulator starts
/opt/retropie/emulators/retroarch/bin/retroarch --version &>/dev/null
/usr/bin/emulationstation --help &>/dev/null

RUNNING_CMD=0

if mountpoint -q "/media/usb0"; then
   autostart_path=/media/usb0/retropie-overlay/autostart.rc
fi

if [[ -f "$autostart_path" ]]; then
    source "$autostart_path"
    export RUNCOMMAND_CONF="fakeFile"
    if [[ -z "$AUTOSTART_VMODE" ]]; then
        AUTOSTART_VMODE=0
    fi

    if [[ -v AUTOSTART_DELAY ]]; then
	    sleep $AUTOSTART_DELAY
    fi

    autostart_rom_path="$retropie_path/$AUTOSTART_ROM"
    autostart_script_path="$retropie_path/$AUTOSTART_SCRIPT"

    if [[ -n "$AUTOSTART_ROM" && -f "$autostart_rom_path" && -n "$AUTOSTART_SYSTEM" ]]; then
        RUNNING_CMD=1
        ES_ARGS="--no-splash"
        DISABLE_MENU=1 $runcmd $AUTOSTART_VMODE _SYS_ $AUTOSTART_SYSTEM "$autostart_rom_path"
    elif [[ -n "$AUTOSTART_SCRIPT" && -f "$autostart_script_path" ]]; then
        RUNNING_CMD=1
        ES_ARGS="--no-splash"
        DISABLE_MENU=1 $runcmd $AUTOSTART_VMODE _PORT_ $ports_sys "$autostart_script_path"
    fi
fi

if [[ $RUNNING_CMD -eq 0 ]]; then
    sudo plymouth --ping
    if [[ $? -eq 0 ]]; then
        sudo plymouth --quit
        sudo plymouth --wait
    fi
fi

emulationstation "$ES_ARGS" --no-exit #auto

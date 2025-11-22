sudo plymouth --ping
if [[ $? -eq 0 ]]; then
    echo "Runcommand onlaunch - exiting plymouth" >&2
    sudo plymouth --quit
    sudo plymouth --wait
fi

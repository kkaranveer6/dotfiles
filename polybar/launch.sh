#!/bin/bash

# Kill any running polybar instances
killall -q polybar

# Wait until all instances have exited
while pgrep -x polybar >/dev/null; do sleep 0.5; done

# Launch one bar per connected monitor
# The MONITOR env var tells polybar which screen to use
for monitor in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    MONITOR=$monitor polybar --reload main 2>&1 | tee -a /tmp/polybar-"$monitor".log &
    disown
done

echo "Bars launched on: $(xrandr --query | grep ' connected' | cut -d' ' -f1 | tr '\n' ' ')"

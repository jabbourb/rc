#! /bin/sh

xrandr|grep -v "^eDP1"|grep -q "\sconnected" && xrandr --output eDP1 --off
feh --bg-scale wallpaper/Che-Guevara-Wallpaper.jpg

pulseaudio --check || start-pulseaudio-x11&
urxvtd -q -o -f
#disable beeps
xset -b
xbindkeys &
setxkbmap us_intl
xmodmap .xmodmaprc &

LOCK_CMD="xautolock -detectsleep -locker '/usr/bin/i3lock -i /home/bassam/wallpaper/bsod.png -p win -c 0000ac'"

# Will match either built-in or HDMI output
# Don't forget to disable stream device reading in /etc/pulse/default.pa
# which would otherwise override the fallback sink
if pactl list sinks|grep -q OneLink_Dock; then
    # HDMI
    pactl set-default-sink 1 &
    # 30mn before turning screen off
    xset dpms 1800 0 0 &
    eval $LOCK_CMD '-time 60' &
else
    pactl set-default-sink 1 &
    xset dpms 900 0 0 &
fi

exec i3

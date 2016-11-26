#!/bin/bash

# requires: xdotool, wmctrl

# usage:
#   resize_window.sh {left|right} {short|long}
#     e.g. 
#   $ ./resize_window.sh right short

# TODO 
#   - support different resolutions (mixed as well)
#   - support more than 2 displays
#   - support monitor 'hopping'

# references:
#   https://linuxacademy.com/blog/linux/conditions-in-bash-scripting-if-statements#double-parenthesis-syntax
#   http://unix.stackexchange.com/questions/53150/how-do-i-resize-the-active-window-to-50-with-wmctrl
#   http://www.tldp.org/LDP/abs/html/comparison-ops.html

CHARS_WIDE=86
ASSUMED_WIDTH=1920
ASSUMED_HEIGHT=1080

PIXELS_PER_CHAR=9


# get width of screen and height of screen
SCREEN_WIDTH=$(xwininfo -root | awk '$1=="Width:" {print $2}')
#SCREEN_HEIGHT=$(xwininfo -root | awk '$1=="Height:" {print $2}')

PROCESS_NAME=$(cat /proc/$(xdotool getwindowpid $(xdotool getwindowfocus))/comm)

# HACK for using 'chrome' system menu vs desktop menu
if [ "$PROCESS_NAME" = "chrome" ]; then
  TOPMARGIN=18
else
  TOPMARGIN=30
fi


UPPER_LEFT_X=$(xwininfo -id $(xdotool getactivewindow) | sed -n -e "s/^ \+Absolute upper-left X: \+\([0-9]\+\).*/\1/p")

if [ "$2" = "long" ]; then
  W=$(( $ASSUMED_WIDTH - ($CHARS_WIDE*$PIXELS_PER_CHAR) ))
elif [ "$2" = "short" ]; then
  W=$(($CHARS_WIDE*$PIXELS_PER_CHAR ))
fi

H=$(( $ASSUMED_HEIGHT - 2 * $TOPMARGIN ))

CURRENT_MONITOR=0

if (($SCREEN_WIDTH > $ASSUMED_WIDTH)); then
  # screen width > 1920, two monitors
  CURRENT_MONITOR=$(($UPPER_LEFT_X / $ASSUMED_WIDTH))
fi

Y=0

if [ "$1" = "left" ]; then
  X=$(( $CURRENT_MONITOR*$ASSUMED_WIDTH ))
elif [ "$1" = "right" ]; then
  X=$(( $CURRENT_MONITOR*$ASSUMED_WIDTH + ($ASSUMED_WIDTH-$W) ))
fi

wmctrl -r :ACTIVE: -b remove,maximized_vert,maximized_horz && wmctrl -r :ACTIVE: -e 0,$X,$Y,$W,$H

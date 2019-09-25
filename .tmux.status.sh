#!/bin/bash
TIMELEFT=${1:-INVALID}
if [[ $TIMELEFT == "INVALID" ]]; then
  TIMELEFT=0
fi
COLORS=(
  196 # red
  202 208 214 220 # oranges
  226 226 # yellow
  190 154 118 # yellow-greens
  046 046 046 # green
  047 048 049 050 # green-cyans
  051 # cyan
)
HOURS=$(( $TIMELEFT / (60 * 60) ))
MINUTES=$(( $TIMELEFT / 60 - $HOURS * 60 ))
TOTAL_MINUTES=$(( $HOURS * 60 + $MINUTES ))
THRESHOLD=$(( 8 * 60 * 60 ))
if [[ ! $TIMELEFT -lt $THRESHOLD ]]; then
  GRADIENTINDEX=$(( ${#COLORS[@]} - 1 ))
elif [[ ! $TIMELEFT -gt 0 ]]; then
  GRADIENTINDEX=0
else
  GRADIENTINDEX=$(( ${#COLORS[@]} * $TIMELEFT / $THRESHOLD ))
fi
COLOR=${COLORS[$GRADIENTINDEX]}
if [[ $HOURS -gt 99 ]]; then
  HOURS=99
  MINUTES=59
fi
if [[ $HOURS -lt 10 ]]; then
  HOURS=0$HOURS
fi
if [[ $MINUTES -lt 10 ]]; then
  MINUTES=0$MINUTES
fi
# echo -en "\033[48;5;${COLOR}m"
if [[ $TIMELEFT -le 0 ]]; then
  echo -n " #[bg=colour${COLOR}][00m"
elif [[ $TOTAL_MINUTES -le 99 ]]; then
  if [[ $TOTAL_MINUTES -lt 10 ]]; then
    TOTAL_MINUTES=0$TOTAL_MINUTES
  fi
  echo -n " #[bg=colour${COLOR}][${TOTAL_MINUTES}m"
else
  echo -n " #[bg=colour${COLOR}][${HOURS}h"
fi
if [[ -f /var/run/reboot-required ]]; then
  echo "|#[bg=colour${COLORS[0]}]REBOOT#[bg=colour${COLOR}]]"
else
  echo "]"
fi

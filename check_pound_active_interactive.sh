#!/bin/sh

# check_pound_active_interactive.sh - Script for determining pound thread usage repeatedly.
#
# This script can be useful to run when you want to monitor pound thread usage, perhaps
# whilst running load tests and experimenting with pound settings.

# Customisable variables
CHECK_POUND_ACTIVE_SLEEP_TIME=2 # number of seconds to sleep between each check. Don't set this too quickly, as it might cause load itself potentially.
POUND_PID_PATH=/var/run/pound.pid

echo "Press Ctrl-c to cancel."

while [ 1 -eq 1 ] ; do
  # Read in PID file each time, incase pound gets restarted during testing.
  if [ ! -e $POUND_PID_PATH ]; then
    echo "Pound PID file not found. Will try again in 5 seconds."
    sleep 5
    continue
  fi;

  POUND_PID=$((`cat $POUND_PID_PATH`+1))
  
  POUND_OUTPUT=`find /proc/${POUND_PID}/task/*/syscall -type f -exec cat {} \; -exec echo "|" \;`

  ACTIVE=0
  INACTIVE=0
  TOTAL=0

  for i in $(echo $POUND_OUTPUT | tr "|" "\n")
  do
    if [[ "$i" -eq "202" ]]; then
     INACTIVE=$[$INACTIVE +1]
     TOTAL=$[$TOTAL +1]

    elif [[ "$i" -eq "7" || "$i" -eq "35" ]]; then
     ACTIVE=$[$ACTIVE +1]
     TOTAL=$[$TOTAL +1]
    fi

  done

  # There are usually around 3 active threads that shouldn't be counted.
  ACTIVE=$[$ACTIVE -3]
  TOTAL=$[$TOTAL -3]

  # Using the bc tool to do floating point calculations
  PERC=$(echo "$ACTIVE*100/$TOTAL" | bc)

  # Debug stuff
  #echo "Active/Total/Percentage: $ACTIVE/$TOTAL/$PERC"

  if [ $PERC -lt 70 ] ; then
    STATUSTXT=OK
    STATUS=0
  elif [ $PERC -lt 80 ] ; then
    STATUSTXT=WARNING
    STATUS=1
  else
    STATUSTXT=CRITICAL
    STATUS=2
  fi

  echo -ne "$STATUSTXT - percentage active threads: $PERC%        \r"

  sleep $CHECK_POUND_ACTIVE_SLEEP_TIME

done # End while loop


# Break to a new line, due to the -ne above.
echo ""


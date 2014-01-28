#!/bin/sh

# check_pound_active.sh - Nagios Plugin for determining pound thread usage.
#
# Requires nagios to be setup with sudo access as, pound stores its taskfiles as owned by root. See this thread 
# for more details about setting up nagios up with root:
# http://blog.gnucom.cc/2009/configuring-nagios-to-run-privileged-or-root-commands-with-nrpe/
#
# Followed nagios plugin guidelines found here:
# http://www.kernel-panic.it/openbsd/nagios/nagios6.html

if [ ! -r /var/run/pound.pid ]; then
  echo "Error: No permission to pound.pid file"
  exit 3; # State unknown
fi;

POUND_PID=$((`cat /var/run/pound.pid`+1))
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

echo "$STATUSTXT - percentage active threads: $PERC%|perctageactivethreads=$PERC%"
exit $STATUS



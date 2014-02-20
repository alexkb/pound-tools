Various tools for monitoring Pound usage
====================

Useful links:

  *  [http://www.apsis.ch/pound](http://www.apsis.ch/pound) - Official Pound website.
  *  [http://linux.die.net/man/8/pound](http://linux.die.net/man/8/pound) - Man page with all Pound configuration settings.
  *  [https://github.com/alexkb/pound-tools](https://github.com/alexkb/pound-tools) - original source of these scripts.

check\_pound\_active.sh
-----------
This script can be used in nagios for monitoring and tracking thread usage. However, it requires nagios to be setup with sudo access as pound stores its taskfiles as owned by root. See this thread for more details about [setting up nagios up with root](http://blog.gnucom.cc/2009/configuring-nagios-to-run-privileged-or-root-commands-with-nrpe/). 

check\_pound\_active\_interactive.sh
-----------
This script can be used to provide live pound thread usage activity, perhaps while you're running load tests or monitoring a sites usage.

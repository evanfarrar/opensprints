#
# Regular cron jobs for the opensprints package
#
0 4	* * *	root	[ -x /usr/bin/opensprints_maintenance ] && /usr/bin/opensprints_maintenance

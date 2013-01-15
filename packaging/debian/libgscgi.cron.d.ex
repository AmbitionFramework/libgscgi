#
# Regular cron jobs for the libgscgi package
#
0 4	* * *	root	[ -x /usr/bin/libgscgi_maintenance ] && /usr/bin/libgscgi_maintenance

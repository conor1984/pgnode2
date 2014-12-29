# this script should do the following 3 things, promote db , copy
# pgbouncer conf to pgbouncer server and restart the service
pg_ctl -D $PGDATA promote
rsync --delete -a -k --perms  $PGBOUNCE/pgbouncer.ini postgres@pgbouncer:$PGBOUNCE/
#reload
ssh postgres@pgbouncer pgbouncer -R -d $PGBOUNCE/pgbouncer.ini
#email
echo "pgnode 1 has failed" | mail -s "node failure"  conor.nagle@firmex.com
#tell node3 to follow
#ssh maximus@pgnode3 repmgr -f $PGREP/repmgr.conf standby follow

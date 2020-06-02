# Stream Replication Setup for PGSQL

1. Install postgres in the primary and standby server as usual. This requires only configure, make and make install.
2. Create the initial database cluster in the primary server as usual, using initdb.

```
/usr/pgsql-12/bin/postgresql-12-setup initdb
```

3. Create an user named replication with REPLICATION privileges.

```
CREATE ROLE replication WITH REPLICATION PASSWORD 'password' LOGIN
```
4. Set up connections and authentication on the primary so that the standby server can successfully connect to the replication pseudo-database on the primary.

$ $EDITOR postgresql.conf


listen_addresses = '*'

$ $EDITOR pg_hba.conf

```
# The standby server must connect with a user that has replication privileges.
# TYPE  DATABASE        USER            ADDRESS                 METHOD
  host  replication     replication     192.168.0.20/32         md5
```

The following parameters on the master are considered as mandatory when setting up streaming replication.

archive_mode : Must be set to ON to enable archiving of WALs.

wal_level : Must be at least set to hot_standby  until version 9.5 or replica  in the later versions.

max_wal_senders : Must be set to 3 if you are starting with one slave. For every slave, you may add 2 wal senders.

wal_keep_segments : Set the WAL retention in pg_xlog (until PostgreSQL 9.x) and pg_wal (from PostgreSQL 10). Every WAL requires 16MB of space unless 
you have explicitly modified the WAL segment size. You may start with 100 or more depending on the space and the amount of WAL that could be generated during a backup.

archive_command : This parameter takes a shell command or external programs. It can be a simple copy command to copy the WAL segments to another 
location or a script that has the logic to archive the WALs to S3 or a remote backup server.

listen_addresses : Specifies which IP interfaces could accept connections. You could specify all the TCP/IP addresses on which the server could listen to connections from client. ‘*’ means all available IP interfaces. The default : localhost allows only local TCP/IP connections to be made to the postgres server.

hot_standby : Must be set to ON on standby/replica and has no effect on the master. However, when you setup your replication, parameters set on the 
master are automatically copied. This parameter is important to enable READS on slave. Otherwise, you cannot run your SELECT queries against slave.



$ $EDITOR postgresql.conf

```
# To enable read-only queries on a standby server, wal_level must be set to
# "hot_standby". But you can choose "archive" if you never connect to the
# server in standby mode.

wal_level = hot_standby

# Set the maximum number of concurrent connections from the standby servers.
max_wal_senders = 5

# To prevent the primary server from removing the WAL segments required for
# the standby server before shipping them, set the minimum number of segments
# retained in the pg_xlog directory. At least wal_keep_segments should be
# larger than the number of segments generated between the beginning of
# online-backup and the startup of streaming replication. If you enable WAL
# archiving to an archive directory accessible from the standby, this may
# not be necessary.
wal_keep_segments = 32

# Enable WAL archiving on the primary to an archive directory accessible from
# the standby. If wal_keep_segments is a high enough number to retain the WAL
# segments required for the standby server, this is not necessary.
archive_mode    = on
archive_command = 'cp %p /path_to/archive/%f'
```

### SQL Command to setup this
```
ALTER SYSTEM SET wal_level TO 'hot_standby';
ALTER SYSTEM SET archive_mode TO 'ON';
ALTER SYSTEM SET max_wal_senders TO '5';
ALTER SYSTEM SET wal_keep_segments TO '10';
ALTER SYSTEM SET listen_addresses TO '*';
ALTER SYSTEM SET hot_standby TO 'ON';
```
### Load config

```
psql -U postgres -p 5432 -c "select pg_reload_conf()"
```

On Slave
```
pg_basebackup -h 192.168.0.28 -U replicator -p 5432 -D $PGDATA -P -Xs -R
```

### Potential error

```
pg_basebackup: error: directory "/var/lib/pgsql/12/data" exists but is not empty
```

Create a recovery command file in the standby server; the following parameters are required for streaming replication.

$ $EDITOR recovery.conf
```
# Note that recovery.conf must be in $PGDATA directory.
# It should NOT be located in the same directory as postgresql.conf

# Specifies whether to start the server as a standby. In streaming replication,
# this parameter must to be set to on.
standby_mode          = 'on'

# Specifies a connection string which is used for the standby server to connect
# with the primary.
primary_conninfo      = 'host=192.168.0.10 port=5432 user=replication password=password'

# Specifies a trigger file whose presence should cause streaming replication to
# end (i.e., failover).
trigger_file = '/path_to/trigger'

# Specifies a command to load archive segments from the WAL archive. If
# wal_keep_segments is a high enough number to retain the WAL segments
# required for the standby server, this may not be necessary. But
# a large workload can cause segments to be recycled before the standby
# is fully synchronized, requiring you to start again from a new base backup.
restore_command = 'cp /path_to/archive/%f "%p"'
```

Start postgres in the standby server. It will start streaming replication.


## How to Monitor Replication

On Master
```
select usename,application_name,client_addr,backend_start,state,sync_state from pg_stat_replication ;
  usename   | application_name |  client_addr   |         backend_start         |   state   | sync_state
------------+------------------+----------------+-------------------------------+-----------+------------
 replicator | walreceiver      | 178.128.228.63 | 2020-06-02 00:45:54.011998+00 | streaming | async
(1 row)
```

On Slave

```
postgres=# select * from pg_stat_wal_receiver;
 pid  |  status   | receive_start_lsn | receive_start_tli | received_lsn | received_tli |      last_msg_send_time       |     last_msg_receipt_time     | latest_end_lsn |        latest_end_time        | slot_name |  sender_host  | sender_port |
                                                                            conninfo
------+-----------+-------------------+-------------------+--------------+--------------+-------------------------------+-------------------------------+----------------+-------------------------------+-----------+---------------+-------------+----------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 1148 | streaming | 0/8000000         |                 1 | 0/81BA090    |            1 | 2020-06-02 00:55:43.979656+00 | 2020-06-02 00:55:43.980689+00 | 0/81BA090      | 2020-06-02 00:50:13.266865+00 |           | 165.227.44.48 |        5432 | user=replicator password=**
****** dbname=replication host=165.227.44.48 port=5432 fallback_application_name=walreceiver sslmode=prefer sslcompression=0 gssencmode=prefer krbsrvname=postgres target_session_attrs=any
(1 row)

```


### How to do failover

Create the trigger file in the standby after the primary fails.

How to stop the primary or the standby server

Shut down it as usual (pg_ctl stop).

How to restart streaming replication after failover

Repeat the operations from 6th; making a fresh backup, some configurations and starting the original primary as the standby. The primary server doesn't 
need to be stopped during these operations.

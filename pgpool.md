# PGPool -II Install and Setup

## Install the package ( CentOS 7 )

```
yum install -y http://www.pgpool.net/yum/rpms/4.1/redhat/rhel-7-x86_64/pgpool-II-release-4.1-1.noarch.rpm
yum install pgpool-II-pg12-devel pgpool-II-pg12-extensions pgpool-I2-pg12 pgpool-II-pg12-debuginfo -y
systemctl enable pgpool.service
systemctl restart pgpool.service
```

Configure pgpool.conf

```
# - Backend Connection Settings -

backend_hostname0 = '165.227.44.48'
                                   # Host name or IP address to connect to for backend 0
backend_port0 = 5432
                                   # Port number for backend 0
backend_weight0 = 1
                                   # Weight for backend 0 (only in load balancing mode)
backend_data_directory0 = '/var/lib/pgsql/12/data'
                                   # Data directory for backend 0
backend_flag0 = 'ALLOW_TO_FAILOVER'
                                   # Controls various backend behavior
                                   # ALLOW_TO_FAILOVER, DISALLOW_TO_FAILOVER
                                   # or ALWAYS_MASTER
backend_application_name0 = 'server0'
                                   # walsender's application_name, used for "show pool_nodes" command

backend_hostname1 = '178.128.228.63'
backend_port1 = 5432
backend_weight1 = 1
backend_data_directory1 = '/var/lib/pgsql/12/data'
backend_flag1 = 'ALLOW_TO_FAILOVER'
backend_application_name1 = 'server1'

```

Enable Load balance

```
#------------------------------------------------------------------------------
# LOAD BALANCING MODE
#------------------------------------------------------------------------------

load_balance_mode = on
                                   # Activate load balancing mode
                                   # (change requires restart)
```
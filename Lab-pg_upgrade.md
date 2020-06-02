## for centos 7 - lab for major version upgrade from 9.6 to 12 using pg_upgrade

## Install pg 9.6 as major

```

 yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm
 yum install -y postgresql96 postgresql96-server postgresql96-contrib wget
 /usr/pgsql-9.6/bin/postgresql96-setup initdb
 systemctl start postgresql-9.6
 systemctl status postgresql-9.6
```

## Create sampledatabase
```
su - postgres
createdb sampledatabase
```
## instering sample dataset
```
wget https://raw.githubusercontent.com/morenoh149/postgresDBSamples/master/worldDB-1.0/world.sql
psql -d sampledatabase -f world.sql
```
# varify that database was imported
```
psql
\l
\c sampledatabase
\dt
\q
```
## Stop postgresql servers
```
systemctl stop postgresql-9.6
```
## installing version 12
```
yum install -y postgresql12 postgresql12-contrib postgresql12-server 
/usr/pgsql-12/bin/postgresql-12-setup initdb
```
## executing pg_upgrade from new version binary
```
/usr/pgsql-12/bin/pg_upgrade --check \
--old-datadir=/var/lib/pgsql/9.6/data \
--new-datadir=/var/lib/pgsql/12/data \
--old-bindir=/usr/pgsql-9.6/bin \
--new-bindir /usr/pgsql-12/bin
```
# run same upgrade without --check option
```
/usr/pgsql-12/bin/pg_upgrade \
--old-datadir=/var/lib/pgsql/9.6/data \
--new-datadir=/var/lib/pgsql/12/data \
--old-bindir=/usr/pgsql-9.6/bin \
--new-bindir /usr/pgsql-12/bin
```
## varify data was inserted into new databse after starting postgresql server
```
 systemctl start postgresql-12
 systemctl status postgresql-12
 ```
 
 ## Analyze and cleanup
 
 Optimizer statistics are not transferred by pg_upgrade so,
once you start the new server, consider running:
 
 ```
 ./analyze_new_cluster.sh

 "/usr/pgsql-12/bin/vacuumdb" --all --analyze-only
```

## psql Commands

psql -d database -U  user -W

psql -h host -d database -U user -W

psql -U user -h host "dbname=db sslmode=require"

## Import database

psql -d sampledatabase -f world.sql

postgres=# \c dvdrental

List available databases

\l

List available tables

\dt
Note that this command shows the only table in the currently connected database.

Describe a table

\d table_name

List available schema

\dn

List available functions

\df

List available views

\dv


SELECT version();

\g

Command history

\s

If you want to save the command history to a file, you need to specify the file name followed the \s command as follows:

\s filename

Execute psql commands from a file

\i filename

# Configuration

systemctl start postgresql-12

shared_preload_libraries = 'pg_stat_statements'

yum install http://www.pgpool.net/yum/rpms/4.1/redhat/rhel-7-x86_64/pgpool-II-release-4.1-1.noarch.rpm

systemctl restart pgpool.service
psql -h localhost -p 9999 t -c "select current_setting('port') from ts limit 1"

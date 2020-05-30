yum install https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm
yum install postgresql12
yum install postgresql12-server -y
usr/pgsql-12/bin/postgresql-12-setup initdb
/usr/pgsql-12/bin/postgresql-12-setup initdb
systemctl enable postgresql-12systemctl start postgresql-12
systemctl enable postgresql-12; systemctl start postgresql-12
su - postgres

## Basic Roles


```
CREATE ROLE people WITH PASSWORD 'pass' VALID UNTIL '2022-01-01';

CREATE ROLE bigboss SUPERUSER;

CREATE ROLE admin CREATEDB;

CREATE ROLE security CREATEROLE;


CREATE ROLE mayor;
GRANT mayor TO people;
REVOKE mayor FROM people;
```



## Role Inheritance

CREATE ROLE people LOGIN INHERIT;
CREATE ROLE mayor NOINHERIT;
CREATE ROLE librarian NOINHERIT;
GRANT mayor to people;
GRANT librarian to mayor;

SET ROLE mayor;

SET ROLE librarian;

RESET ROLE;

DROP ROLE role_name;

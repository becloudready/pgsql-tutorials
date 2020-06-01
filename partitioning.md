
## Range Partitioning
```
CREATE TABLE customers (id INTEGER, status TEXT, arr NUMERIC) PARTITION BY RANGE(arr);
CREATE TABLE cust_arr_small PARTITION OF customers FOR VALUES FROM (MINVALUE) TO (25);
CREATE TABLE cust_arr_medium PARTITION OF customers FOR VALUES FROM (25) TO (75);
CREATE TABLE cust_arr_large PARTITION OF customers FOR VALUES FROM (75) TO (MAXVALUE);
INSERT INTO customers VALUES (1,'ACTIVE',100), (2,'RECURRING',20), (3,'EXPIRED',38), (4,'REACTIVATED',144);
SELECT tableoid::regclass,* FROM customers;
```
## List Partitioning
```
CREATE TABLE customers (id INTEGER, status TEXT, arr NUMERIC) PARTITION BY LIST(status);
CREATE TABLE cust_active PARTITION OF customers FOR VALUES IN ('ACTIVE');
CREATE TABLE cust_archived PARTITION OF customers FOR VALUES IN ('EXPIRED');
CREATE TABLE cust_others PARTITION OF customers DEFAULT;
INSERT INTO customers VALUES (1,'ACTIVE',100), (2,'RECURRING',20), (3,'EXPIRED',38), (4,'REACTIVATED',144);
SELECT tableoid::regclass,* FROM customers;
```
## Partition by Hash

CREATE TABLE people (
    id int not null,
    birth_date date not null,
    country_code character(2) not null,
    name text
) PARTITION BY HASH (id);

CREATE TABLE people_1 PARTITION OF people
    FOR VALUES WITH (MODULUS 3, REMAINDER 0);

CREATE TABLE people_2 PARTITION OF people
    FOR VALUES WITH (MODULUS 3, REMAINDER 1);

CREATE TABLE people_3 PARTITION OF people
    FOR VALUES WITH (MODULUS 3, REMAINDER 2);

INSERT INTO people (id, birth_date, country_code, name) VALUES
   (1, '2000-01-01', 'US', 'John'),
   (2, '2000-02-02', 'IT', 'Jane'),
   (3, '2001-03-03', 'FR', 'Bob');

SELECT schemaname,relname,n_live_tup 
   FROM pg_stat_user_tables 
   ORDER BY n_live_tup DESC;

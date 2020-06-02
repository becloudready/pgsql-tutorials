
## Open a Terminal we call this session-1
connect to database server
connect to world database 

\c world

BEGIN ;  # THIS WILL KEEP CONNECTION ALIVE
BEGIN  # will get this output

UPDATE country SET continent='Europe' WHERE code='USA';   

UPDATE 1  # will give this output - started query on row - USA , hence row - USA  is in use



## Open another Terminal we call this session-2

connect to database server
connect to world database 

\c world

BEGIN ;  
BEGIN # will get this output

UPDATE country SET continent='Asia' WHERE code='GBR';
UPDATE 1  # will give this output - started query on row - GBR , hence row - GBR  is in use

UPDATE country SET indepyear=1111 WHERE code='USA';  # now this will go in waiting as row - USA is still in use by session 1


## Go to session 1

UPDATE country SET indepyear=1112 WHERE code='GBR';  # row - GBR is in use by session 2 hence it will generate deadlock error

ERROR:  deadlock detected
DETAIL:  Process 22208 waits for ShareLock on transaction 806; blocked by process 22256.
Process 22256 waits for ShareLock on transaction 805; blocked by process 22208.
HINT:  See server log for query details.
CONTEXT:  while updating tuple (4,27) in relation "country"

postgresql automatically break the lock 


## Go to session 2

and now query is completed


now end both session by executing below command in both session and notice the output

end;

session 2 will say - COMMIT
but 
session 1 will say - ROLLBACK - that means - " UPDATE country SET indepyear=1112 WHERE code='GBR'; " was not successfully executed

For more details we can see the log in our PostgreSQL server
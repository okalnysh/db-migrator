# DB Migration Project

The main goal of the project is to execute sql scripts located in the `migration-scrips` folder one by one.
The order of the scripts execution determines by the name of the file (asc order).

Each script will be executed only once.
If the script should be re-executed - change the name of the file.
To provide that capability, the `utils.ScriptExecutionLog` table will be created in a target database.

How to build the image
```shell
docker build --tag db-migrator:1.0.0 .
```

Set the following environment variables:
```
SQLCMDSERVER	    -S
SQLCMDDBNAME	    -d
SQLCMDUSER	        -U
SQLCMDPASSWORD	    -P
SQLCMDSTATTIMEOUT	-t  "0" = wait indefinitely (1-65535 seconds)
```

Call examples
```shell
sqlcmd -Q "select 1;"
sqlcmd -i temp.sql
```

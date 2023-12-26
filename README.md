# DB Migration Project

The main goal of the project is to execute sql scripts located in the `migration-scripts` folder one by one.
The order of the scripts execution determines by the name of the file (asc order).

Each script will be executed only once.
If the script should be re-executed - change the name of the file or use `remove` script (see below).
To provide that capability, the `utils.ScriptExecutionLog` table will be created in a target database.

## How to build the docker image
```shell
docker rmi -f db-migrator:1.0
docker build --tag db-migrator:1.0 .
```

## How to initialize db
Initialization process creates objects needed for db-migrator work properly.
The init process is idempotent, so it can be run many times without any harm to the existing objects.
```shell
docker run --rm -it db-migrator:1.0 /init.sh
```

## How to run migration
```shell
docker run --rm -it -v ./migration-scripts/:/migration-scripts db-migrator:1.0 /migrate.sh
```

## How to remove log of one migration script so it will be re-ran with the next migration
```shell
docker run --rm -it db-migrator:1.0 /remove.sh __script_name_without_sql_extension
```

## How to clean db
The cleaning process removes all objects created by the initialization script.
Be aware that you will lost all execution logs of migration scripts.
After that script you have to `init` database again.
All migrations will be re-runned again.
```shell
docker run --rm -it db-migrator:1.0 /clean-all.sh
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

# DB Migration Project

## Overview
This project aims to execute SQL scripts sequentially from the `migration-scripts` folder. <br>
The execution order of these scripts is determined by their filenames, arranged in ascending order. <br>
Each script is run only once. <br>
To re-execute a script, you must either rename it or use the `remove` script (details provided below). <br>

## Building the Docker Image
To build the Docker image, use the following commands:
```shell
docker rmi -f db-migrator:1.0
docker build -t db-migrator:1.0 -t db-migrator:latest .
```

## The following environment variables should be set
```shell
export SQLCMDSERVER_QA=_qa_sqlserver_address_or_hostname
export SQLCMDSERVER_PROD=_prod_sqlserver_address_or_hostname
export SQLCMDUSER=_sqlserver_user_name
export SQLCMDPASSWORD=_sqlserver_user_password
```

## Migration-script Directory
The actual `migration-scripts` directory can be specified by editing the appropriate `docker-compose` file.
By default it points to the directory with test scripts.
```yaml
    volumes:
      - ./migration-scripts:/migration-scripts
```

## Initializing the Database
The initialization process sets up essential database objects (like schema, table, and stored procedures) necessary for the db-migrator to function correctly. <br>
This process is idempotent, meaning it can be executed multiple times without affecting existing objects. <br>
Use this command to initialize database:
```shell
docker compose -f docker-compose-qa.yml run --rm migrator init.sh
```

## Running the Migration
To start the migration process, execute the following command:
```shell
docker compose -f docker-compose-qa.yml run --rm migrator migrate.sh
```

## Removing a Migration Script From Log
If you need to re-run a specific migration script, you can remove its log with the command below. <br>
Replace `__script_name` with the actual script name, excluding the .sql file extension:
```shell
docker compose -f docker-compose-qa.yml run --rm migrator remove.sh __script_name
```

## Cleaning the Database
### !!! WARNING !!!
This is a destructive process and should never be executed under normal circumstances.<br>
It could only be used during development.<br><br>

The cleaning process involves removing all objects created during initialization. <br>
Note that this will also erase all migration script execution logs. <br>
After running this script, you will need to re-initialize database. <br>
All migration SQL scripts will be executed again during migration. <br>
Use the following command to clean the database:
```shell
docker compose -f docker-compose-qa.yml run --rm migrator clean-all.sh
```
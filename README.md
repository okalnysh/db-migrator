# DB Migration Project

The main goal of the project is to execute sql scripts located in the `scrips` folder one by one.
The order of the scripts execution determines by the name of the file (asc order).

Each script will be executed only once.
To provide that capability, the `utils.ScriptExecutionLog` table will be created in a target database.

How to build the image
```shell
docker build .
```

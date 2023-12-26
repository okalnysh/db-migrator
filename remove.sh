#!/bin/bash

sqlcmd -Q "delete from okay.MigrationsLog where ScriptName='$1';"
sqlcmd -Q "raiserror('[INFO] Migration script [$1] was removed', 0, 1) with nowait;"
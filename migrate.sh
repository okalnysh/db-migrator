#!/bin/bash

form_temp_file(){
    file_name=${file_path##*/};
    script_name=${file_name%.sql};
    sql_content=$(cat $file_path);

    sql=$(cat <<EOF
    declare @ScriptName varchar(256) = '$script_name';
    set nocount on;
    set xact_abort on;

    if not exists(select 1 from utils.UpdateScriptsLog ul where ul.ScriptName = @ScriptName)
    begin
        exec utils.UpdateScriptStarted @ScriptName;
        begin transaction;
        begin try

            $sql_content

            commit;
        end try
        begin catch
            if @@trancount > 0 rollback;
            throw;
        end catch;
        exec utils.UpdateScriptEnded @ScriptName;
    end
    go
EOF
    );
    rm -f temp.sql;
    echo "$sql" >> temp.sql;
}


for file_path in ./migration-scripts/*.sql; do
    [ -e "$file_path" ] || continue;
    form_temp_file
    sqlcmd -i temp.sql
done
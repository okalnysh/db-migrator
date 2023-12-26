#!/bin/bash

prepare_schema_sql(){
    sql=$(cat <<EOF
    if exists(select * from sys.schemas where [name] = 'okay')
        exec sp_executesql @statement=N'drop schema okay;'
    go
EOF
    );
}

prepare_table_sql(){
    sql=$(cat <<EOF
    if exists(
        select 1 
        from
            sys.tables t
            inner join sys.schemas s on s.[schema_id] = t.[schema_id]
        where
            t.[name] = 'MigrationsLog'
            and s.[name] = 'okay'
    )
    begin
        drop table okay.MigrationsLog;
    end
    go
EOF
    );
}

prepare_proc3_sql(){
    sql=$(cat <<EOF
    if exists(
        select 1 
        from 
            sys.procedures p
            inner join sys.schemas s on s.[schema_id] = p.[schema_id]
        where
            p.[name] = 'SetScriptEnded'
            and s.[name] = 'okay'
    )
    begin
        drop procedure okay.SetScriptEnded;
    end
    go
EOF
    );
}

prepare_proc2_sql(){
    sql=$(cat <<EOF
    if exists(
        select 1 
        from 
            sys.procedures p
            inner join sys.schemas s on s.[schema_id] = p.[schema_id]
        where
            p.[name] = 'SetScriptStarted'
            and s.[name] = 'okay'
    )
    begin
        drop procedure okay.SetScriptStarted;
    end
    go
EOF
    );
}

prepare_proc1_sql(){
    sql=$(cat <<EOF
    if exists(
        select 1 
        from 
            sys.procedures p
            inner join sys.schemas s on s.[schema_id] = p.[schema_id]
        where
            p.[name] = 'ShowMessage'
            and s.[name] = 'okay'
    )
    begin
        drop procedure okay.ShowMessage;
    end
    go
EOF
    );
}

exec_sql(){
    rm -f temp.sql;
    echo "$sql" >> temp.sql;
    sqlcmd -i temp.sql
}

prepare_proc3_sql
exec_sql

prepare_proc2_sql
exec_sql

prepare_proc1_sql
exec_sql

prepare_table_sql
exec_sql

prepare_schema_sql
exec_sql
#!/bin/bash

export SQLCMDSERVER="172.31.0.15";
export SQLCMDDBNAME="Pipedrive";
export SQLCMDUSER="azure";
export SQLCMDPASSWORD="wK5PaQAPUVqnt5m4";
export SQLCMDSTATTIMEOUT="1200";

prepare_schema_sql(){
    sql=$(cat <<EOF
    if not exists(select * from sys.schemas where [name] = 'okay')
        exec sp_executesql @statement=N'create schema okay authorization dbo;'
    go
EOF
    );
}

prepare_table_sql(){
    sql=$(cat <<EOF
    if not exists(
        select 1 
        from
            sys.tables t
            inner join sys.schemas s on s.[schema_id] = t.[schema_id]
        where
            t.[name] = N'MigrationsLog'
            and s.[name] = N'okay'
    )
    begin
        create table okay.MigrationsLog
        (
            ScriptName varchar(50) not null, 
            StartTime datetime, 
            EndTime datetime, 
            Duration_sec as datediff(second, StartTime, EndTime) persisted,
            Duration_ms as datediff(ms, StartTime, EndTime) persisted
        );

        alter table okay.MigrationsLog add constraint pk_MigrationsLog primary key clustered (ScriptName) with (data_compression=page);
    end
    go
EOF
    );
}

prepare_proc1_sql(){
    sql=$(cat <<EOF
    if not exists(
        select 1 
        from 
            sys.procedures p
            inner join sys.schemas s on s.[schema_id] = p.[schema_id]
        where
            p.[name] = 'ShowMessage'
            and s.[name] = 'okay'
    )
    begin
        declare @statement nvarchar(4000) = '
        create procedure okay.ShowMessage
            @ScriptName varchar(256),
            @MessageType bit = 0	
        as
        begin
            declare @message varchar(8000), @trailText varchar(25);
            select @trailText = case when @MessageType=0 then ''started'' else ''finished'' end;

            set @message = ''[INFO] Execution of the script ['' + @ScriptName + ''] has '' + @trailText;
            raiserror(@message, 0, 1) with nowait;

            if @MessageType = 1
            begin
                declare @duration int = (select top 1 Duration_sec from okay.MigrationsLog where ScriptName=@ScriptName);
                set @message = ''[INFO] Script execution time: '' + cast(@duration as varchar(12)) + '' sec '';
                raiserror(@message, 0, 1) with nowait;
                raiserror(''-------'', 0, 1) with nowait;
            end
        end;
        ';
        exec sp_executesql @statement;
    end
    go
EOF
    );
}

prepare_proc2_sql(){
    sql=$(cat <<EOF
    if not exists(
        select 1 
        from 
            sys.procedures p
            inner join sys.schemas s on s.[schema_id] = p.[schema_id]
        where
            p.[name] = 'SetScriptStarted'
            and s.[name] = 'okay'
    )
    begin
        declare @statement nvarchar(4000) = '
        create procedure okay.SetScriptStarted
            @ScriptName varchar(50)
        as
        begin
            if not exists(select 1 from okay.MigrationsLog ul where ul.ScriptName = @ScriptName)
            begin
                exec okay.ShowMessage @ScriptName, 0;

                insert into okay.MigrationsLog (ScriptName, StartTime) values(@ScriptName, getdate());
            end;
        end;
        ';
        exec sp_executesql @statement;
    end
    go
EOF
    );
}

prepare_proc3_sql(){
    sql=$(cat <<EOF
    if not exists(
        select 1 
        from 
            sys.procedures p
            inner join sys.schemas s on s.[schema_id] = p.[schema_id]
        where
            p.[name] = 'SetScriptEnded'
            and s.[name] = 'okay'
    )
    begin
        declare @statement nvarchar(4000) = '
        create procedure okay.SetScriptEnded
            @ScriptName varchar(256)
        as
        begin
            if exists(select 1 from okay.MigrationsLog ul where ul.ScriptName = @ScriptName and ul.EndTime is null)
            begin
                update okay.MigrationsLog set EndTime = getdate()	where ScriptName = @ScriptName;

                exec okay.ShowMessage @ScriptName, 1;
            end;
        end;
        ';
        exec sp_executesql @statement;
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

prepare_schema_sql
exec_sql

prepare_table_sql
exec_sql

prepare_proc1_sql
exec_sql

prepare_proc2_sql
exec_sql

prepare_proc3_sql
exec_sql